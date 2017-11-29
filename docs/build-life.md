# Life of a Cirrus CI build

Any build starts with a change pushed to GitHub. Since Cirrus CI is a GitHub Application a webhook event 
will be triggered by GitHub. From the webhook event Cirrus CI will parse a Git branch and a particular SHA 
for the change. Based on parsed information a new build will be created.

After build creation Cirrus CI will use GitHub APIs to download a content of `.cirrus.yml` file for the SHA. Cirrus CI
will parse it and create corresponding tasks defined in the configuration file.

These tasks defined in `.cirrus.yml` file will be dispatched within Cirrus CI to different services responsible for scheduling on 
[supported computing service](docs/supported-computing-services.md). A scheduling service will use appropriate APIs to 
schedule a VM instance or a Docker container on the particular computing service. The scheduling service will also 
configure start-up script that downloads Cirrus CI agent, configures and starts it. Cirrus CI agent is a self-contained 
executable written in Go which means it can be executed anywhere.

Cirrus CI agent will request commands to execute for a particular task and will stream back logs, caches and exit codes 
of the commands upon execution.

Once task finishes the same scheduling service will clean up a VM or a container.

![](media/cirrus-ci-communication.svg)

Image above is a diagram of how Cirrus CI schedules a task on Google Cloud Platform. <span style="color:#2196F3">Blue arrows</span> 
represent API calls and <span style="color:#AED581">green arrow</span> represents unidirectional communication between 
an agent inside a VM or a container and Cirrus CI.

Other things like health checking of the agent and GitHub status reporting are happening at same time as a task is running 
but the main flow was described above. Straight forward and nothing magical. :sweat_smile:

For any question please use official [support channels](support.md).


