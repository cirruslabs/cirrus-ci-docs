---
draft: false
date: 2022-07-07
authors:
  - edigaryev
categories:
  - announcement
  - macos
---

# Isolating network between Tart’s macOS virtual machines

Some time has passed since Cirrus Labs released Tart, an open-source tool to manage and run macOS virtual machines on Apple silicon. As Tart matured, we started using it for Cirrus CI’s macOS VM instances to replace other proprietary solutions.

![](/blog/images/tart-vms.png)

However, there are some roadblocks that prevent us from scaling and running more than one VM on a single host:

<!-- more -->

1. Apple’s EULA only allows [2 additional VMs per host](https://apple.stackexchange.com/a/19941)
2. The NAT networking option provided by the [Virtualization.Framework](https://developer.apple.com/documentation/virtualization) lacks proper isolation and this limits us to only running 1 VM per host

The first problem cannot be solved easily without Apple’s involvement, but the second one seems to be an interesting challenge.

## The Problem

[Virtualization.Framework](https://developer.apple.com/documentation/virtualization) is a high-level framework (compared to [Hypervisor.Framework](https://developer.apple.com/documentation/hypervisor)) and provides three networking options out-of-the box:

* [bridged](https://developer.apple.com/documentation/virtualization/vzbridgednetworkdeviceattachment) — places VMs into the same [broadcast domain](https://en.wikipedia.org/wiki/Broadcast_domain) as one of the network interfaces on host, so that the VMs will be able to receive IP addresses from the corporate DHCP server available on the LAN, for example

* [NAT](https://developer.apple.com/documentation/virtualization/vznatnetworkdeviceattachment) — places VMs into a separate broadcast domain (which includes host, but not LAN) and configures DHCP server on the host itself

* [file handle](https://developer.apple.com/documentation/virtualization/vzfilehandlenetworkdeviceattachment) — converts all of the I/O done by the VM as [send(2)](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/send.2.html) and [recv(2)](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/recv.2.html) on a file descriptor that we provide to the Virtualization.Framework

Tart currently uses the NAT option by default. It’s simple and gets the work done for most of the use-cases.

However, NAT and bridged modes are incompatible with multiple tenants, because they don’t bother about preventing the [ARP spoofing](https://en.wikipedia.org/wiki/ARP_spoofing) and other rogue VM manipulations at all. Any VM controlled by the attacker can divert the traffic destined to another VM by simply answering ARP requests with its own MAC address.

The problem itself is pretty common among virtualization solutions, where some [provide a solution out-of-the box](https://libvirt.org/formatnwfilter.html) and some [require a separate purchase](https://www.vmware.com/se/products/nsx.html).

However, in our case, we are dealing with a virtualization framework that is only starting to shape up, so it looks like we have to come up with a solution by ourselves.

## An obvious, but complicated solution

We’ve first tried to work around the missing isolation by creating a daemon that would inject VM-specific rules into the [PF firewall](https://en.wikipedia.org/wiki/PF_(firewall)), but this approach turned out to be racy by design: you have to constantly catch up with the macOS InternetSharing daemon actions and this is a poor model in terms of security.

A more sound approach would be then to force all the networking to flow through our daemon using the [VZFileHandleNetworkDeviceAttachment](https://developer.apple.com/documentation/virtualization/vzfilehandlenetworkdeviceattachment) and then somehow filter the packets and emit them from the host’s TCP/IP stack.

To achieve this, we could’ve used an [utun device](https://tunnelblick.net/cTunTapConnections.html) and configure the NAT ourselves, but all the little details like interacting with the PF firewall, tweaking [sysctl](https://en.wikipedia.org/wiki/Sysctl)’s and evaluating the routing table in the presence of the non-cooperative InternetSharing daemon(that can overwrite things at any point in time) seemed to represent the same racy behavior as above.

Significant progress happened when we discovered the [vmnet framework](https://developer.apple.com/documentation/vmnet). With that framework, we can create an interface and pipe packets to and from it, and it has the same NAT functionality as the Virtualization.Framework, but on a lower level, which removes the need for the utun device and manual NAT configuration completely.

The only remaining issue was how to parse the packets, as there are no Swift libraries that could do that at the time of writing, which brings us to the [Softnet](https://github.com/cirruslabs/softnet).

## Introducing Softnet

[Softnet](https://github.com/cirruslabs/softnet), unlike Tart, is written in Rust. This complicates things a bit, because we now have to do IPC with the Tart process, however this drawback is fully compensated by the sheer amount of libraries in the Rust ecosystems.

We were able to quickly develop a packet filter with DHCP snooping functionality, which works similarly to the libvirt’s network filter [automatic IP address detection](https://libvirt.org/formatnwfilter.html#automatic-ip-address-detection).

Once started with Softnet, a VM can only communicate with a DHCP server. Once a DHCP server assigns the VM an address, we remember it and allow only traffic from that address. Softnet does not modify any packets, but only drops them when they don’t match the learned VM’s IP.

Finally, Softnet already ships with Tart (when installed via Homebrew) and can be enabled with *--with-softnet* command-line flag when starting a VM:

```bash
brew install cirruslabs/cli/tart
tart clone ghcr.io/cirruslabs/macos-monterey-base:latest monterey-base
tart run --with-softnet monterey-base
```

Note that this method of running requires a passwordless sudo to be configured, for more details see this [Softnet’s installation instructions](https://github.com/cirruslabs/softnet#installing).

## Conclusion

Implementing a user space packet filter involves some overhead, but seems like the only option available at the moment.

Next we are looking forward to roll out the Softnet isolation to the production, which will double the capacity of parallel macOS VMs that the Cirrus CI can run.

Stay tuned and don’t hesitate to send us your feedback either [on GitHub](https://github.com/cirruslabs/tart) or [Twitter](https://twitter.com/cirrus_labs)!
