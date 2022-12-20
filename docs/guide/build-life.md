Any build starts with a change pushed to GitHub. Since Cirrus CI is a GitHub Application, a webhook event 
will be triggered by GitHub. From the webhook event, Cirrus CI will parse a Git branch and the SHA 
for the change. Based on said information, a new build will be created.

After build creation Cirrus CI will use GitHub's APIs to download a content of `.cirrus.yml` file for the SHA. Cirrus CI
will evaluate it and create corresponding tasks.

These tasks (defined in the `.cirrus.yml` file) will be dispatched within Cirrus CI to different services responsible
for scheduling on a [supported computing service](supported-computing-services.md).
Cirrus CI's scheduling service will use appropriate APIs to create and manage a VM instance or a Docker container on the particular computing service. 
The scheduling service will also configure start-up script that downloads the Cirrus CI agent, configures it to send logs back and starts it. Cirrus CI agent is a self-contained executable written in Go which means it can be executed anywhere.

Cirrus CI's agent will request commands to execute for a particular task and will stream back logs, caches,
artifacts and exit codes of the commands upon execution.
Once the task finishes, the scheduling service will clean up the used VM or container.

![communication schema](/assets/images/cirrus-ci-communication.svg)

This is a diagram of how Cirrus CI schedules a task on Google Cloud Platform.
The <span style="color:#2196F3">blue</span> arrows represent API calls and the <span style="color:#AED581">green</span> arrows
represent unidirectional communication between an agent inside a VM or a container and Cirrus CI.
Other chores such as health checking of the agent and GitHub status reporting happen in real time as a task is running.

Straight forward and nothing magical. :sweat_smile:

-----

For any questions, feel free to [contact us](../support.md).
