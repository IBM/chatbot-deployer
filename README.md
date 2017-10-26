# Bluemix Pipeline based Chatbot Deployer

The chatbot deployer is a [Bluemix pipeline](https://console.bluemix.net/docs/services/ContinuousDelivery/pipeline_working.html#pipeline-working) plugin that is to be used in the new [Bot Asset Exchange](https://developer.ibm.com/code/exchanges/bots/).

### How do I use it?

1. Navigate over to the [Bot Asset Exchange](https://developer.ibm.com/code/exchanges/bots/) and click the `Get this bot` button.

![](data/get_bot.png)

2. Log into Bluemix if prompted
3. Choose to create the pipeline
4. That's it! Now now click the _Watson Conversation_ icon to see the new _Watson Conversation_ service (entitled `Bot Asset Exchange Workspaces`) that was just created.
5. Launch the _Watson Conversation_ service, find the workspace (the bot you picked!).

#### As an example:

![](data/launch.gif)

### What's it do?

Clicking the `Get this bot` button will:

* Create an Bluemix DevOps pipeline
* Create a _Watson Conversation_ service called `Bot Asset Exchange Workspaces`
* Upload the `workspace.json` file, which represents the bot you selected, into the newly created service

### Testing it out:

Underneath the covers, we hit the DevOps Service ``https://console.bluemix.net/devops/setup/deploy`` with three arguments:

1. URL escaped repository link, for example ``repository=https%3A%2F%2Fgithub.com%2FIBM%2Fchatbot-deployer``
2. Bot Name, for example ``chatbotName=Chatbot``
3. Workspace URL, for example: ``chatbotWorkspaceURL=chatbotWorkspaceURL=https%3A%2F%2Fgithub.com%2FIBM%2Fchatbot-deployer%2Fraw%2Fmaster%2Fdata%2Fworkspace.json``

Click [this link](https://console.bluemix.net/devops/setup/deploy?repository=https%3A%2F%2Fgithub.com%2FIBM%2Fchatbot-deployer&chatbotName=Chatbot&chatbotWorkspaceURL=https%3A%2F%2Fgithub.com%2FIBM%2Fchatbot-deployer%2Fraw%2Fmaster%2Fdata%2Fworkspace.json) to try it out.

## Privacy Notice

Sample DevOps pipeline that include this package may be configured to track deployments to [IBM Bluemix](https://www.bluemix.net/) and other platforms. The following information is sent to a [Deployment Tracker](https://github.com/IBM/metrics-collector-service) service on each deployment:

* Space ID (`space_id`)
* Conversation Service GUID
* Chatbot Name

This data is collected from the Bluemix DevOps pipeline environment variables in IBM Bluemix. This data is used by IBM to track metrics around deployments of sample applications to IBM Bluemix to measure the usefulness of our examples, so that we can continuously improve the content we offer to you. Only deployments of sample applications that include code to ping the Deployment Tracker service will be tracked.

## Disabling Deployment Tracking

To disable the tracker, Simply put down `yes` in *Disable Metrics Tracker* under the **Delivery Pipeline** section when you create your Bluemix DevOps pipeline.
