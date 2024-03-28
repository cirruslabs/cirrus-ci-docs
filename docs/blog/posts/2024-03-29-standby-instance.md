---
draft: false
date: 2024-03-29
search:
  exclude: true
authors:
  - fkorotkov
categories:
  - announcement
---

## Cirrus CI Persistent Workers Get a Boost with Standby Instances

We're excited to announce a new feature for Cirrus CI persistent workers: **Standby Instances**. This functionality significantly improves scheduling efficiency when dealing with many persistent workers, leading to faster task execution and a smoother CI/CD experience.

### Background: Persistent Workers and Scheduling Challenges

Cirrus CI's persistent workers offer a powerful way to run tasks on dedicated infrastructure, including bare metal and virtual machines. This is ideal for scenarios where you need more control over the environment or want to leverage specific hardware configurations.

However, with many persistent workers, scheduling tasks efficiently can be challenging. Previously, when a task was assigned to a worker, **the persistent worker itself would**:

1. **Pull an image:** This could take several minutes if the image is missing or outdated.
2. **Boot the VM:** This added another 10-20 seconds to the overall task execution time.

This delay could be frustrating, especially when dealing with frequent builds and deployments.

### Introducing Standby Instances: Faster Scheduling, Smoother CI/CD

Standby instances address this challenge by ensuring tasks are assigned to workers that are already prepared. Here's how it works:

* You can now define a **standby configuration** for your persistent workers. This configuration specifies the desired VM image (e.g., a specific macOS version via Tart) and resource requirements (CPU, memory, etc.).
* **Each persistent worker will proactively start and maintain a single standby instance** based on your configuration. This instance is ready to execute tasks immediately, eliminating the image pull and worker startup delays.
* When a task is ready, **the persistent worker itself checks if its standby instance matches the task's isolation and resource requirements**. If it does, the task is executed immediately on the standby instance.
* If the standby instance doesn't match the task's requirements, **the persistent worker will create a new instance** as usual.

**Note:** Cirrus CI itself does not have knowledge of standby instances on persistent workers. The efficiency improvement happens directly on the worker level when there is a match between the task's isolation configuration and the standby instance's isolation.

This new approach offers several benefits:

* **Faster task execution:** By eliminating the initial image pull and worker startup time, tasks can start running immediately, leading to faster feedback and quicker deployments.
* **Smoother CI/CD experience:** With faster and more predictable task execution, your CI/CD pipelines will run more smoothly, reducing bottlenecks and wait times.

**Note:** While standby instances do not directly improve resource utilization, they ensure that resources are used effectively by minimizing the time spent on image pulls and worker startup. This leads to a more efficient CI/CD process overall.

### Example Standby Configuration

Here's an example of how to configure a standby instance for a persistent worker using Tart:

```yaml
standby:
  resources:
    tart-vms: 1
  isolation:
    tart:
      image: ghcr.io/cirruslabs/macos-sonoma-base:latest
      user: admin
      password: admin
      cpu: 4
      memory: 12
```

This configuration ensures that the persistent worker will keep one macOS Sonoma VM running and ready to execute tasks that require this specific environment and resources.

### Conclusion

Standby instances are a powerful way to improve the performance and efficiency of your Cirrus CI persistent workers. We encourage you to try it out and experience the benefits for yourself. If you have any questions or need assistance with configuration, please don't hesitate to reach out to our support team at [support@cirruslabs.org](mailto:support@cirruslabs.org).
