#!/bin/bash -ex

# Download and Install CF CLI
wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | sudo apt-key add -
echo "deb http://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list
sudo apt-get update
sudo apt-get install cf-cli

# Authenticate with CF CLI
cf login -a https://api.ng.bluemix.net -u apikey -p $BLUEMIX_API_KEY -o "Developer Advocacy" -s "Watson Developer Advocacy"

################
# This is a copy of the script in chatbot-deployer/.bluemix/pipeline.yml,
# except we define a CHATBOT_JSON_URL and CHATBOT_NAME here for testing purposes
################

CHATBOT_JSON_URL="https://github.com/IBM/chatbot-deployer/raw/master/data/workspace.json"
CHATBOT_NAME="Test_Chatbot"

# Fetch the workspace json from the marketplace
if ! curl -L -o workspace.json "$CHATBOT_JSON_URL"; then
  echo "Failed to fetch workspace for chatbot $CHATBOT_NAME from $CHATBOT_JSON_URL."
  exit 1
fi

# Always use a constant name for the BAE Workspaces
SERVICE_NAME="Bot Asset Exchange Workspaces"
# List the conversation services, if no conversation exists, create service
# and service key for example:
# $ cf services | grep conversation
# Conversation-hf conversation    free    create succeeded
if ! cf services | grep "$SERVICE_NAME"; then
  echo "Creating new conversation service ... "
  cf create-service conversation free "$SERVICE_NAME"
  cf create-service-key "$SERVICE_NAME" "$SERVICE_NAME"
  echo "============================================================="
  echo "Created new conversation service: SERVICE_NAME: $SERVICE_NAME"
  echo "============================================================="
fi

# Fetch service key name for the service, for example:
# $ cf service-keys Conversation-hf
# Getting keys for service instance Conversation-hf
#
# name
# Credentials-1
# NOTE: Use tail -1 to get the last line in the output
# TODO: What if there are multiple service keys?
CREDENTIALS=$(cf service-keys "$SERVICE_NAME" | tail -1)

# Fetch the service key credentials, parse it with json, for example:
# $ cf service-key Conversation-hf Credentials-1
# Getting key Credentials-1 for service instance Conversation-hf
npm install -g json
jsonkey=$( cf service-key "$SERVICE_NAME" "$CREDENTIALS" | tail -n +3 )
wcuser=$( echo $jsonkey | json username )
wcpass=$( echo $jsonkey | json password )
wcurl=$( echo $jsonkey | json url )

# Upload workspace
resp=$( curl --user $wcuser:$wcpass \
           -H "Content-Type: application/json" \
           -X POST -d @workspace.json \
           $wcurl/v1/workspaces?version=2017-04-21 )
echo $resp | json
WORKSPACE_ID=$( echo $resp | json workspace_id )

# Handle failures
if [ -z "$WORKSPACE_ID" ]; then
  echo "Failed creating new workspace..."
  echo "If too many workspaces already, discard obsolete workspaces using: "
  echo "https://www.ibmwatsonconversation.com"
  exit 1
fi

# Print success
echo "=================================================="
echo "Created new workspace: WORKSPACE_ID: $WORKSPACE_ID"
echo "=================================================="

# Double check that workspace ID matches GET request
resp=$( curl --user $wcuser:$wcpass -X GET \
        $wcurl/v1/workspaces/$WORKSPACE_ID?version=2017-04-21 )

status=$?
echo $resp| json
resp_wsid=$( echo $resp | json workspace_id )
if [ $status -ne 0 ] || [ "$resp_wsid" != "$WORKSPACE_ID" ]; then
  echo "Invalid workspace: $WORKSPACE_ID"
  echo "Administer your workspaces at: https://www.ibmwatsonconversation.com"
  exit 1
fi
