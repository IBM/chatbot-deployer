#! /usr/bin/env python

from __future__ import print_function
import json
import os
import requests
from subprocess import check_output

from watson_developer_cloud import ConversationV1


TMP_WORKSPACE = 'https://github.com/IBM/chatbot-deployer/raw/master/tmp/workspace.json'
TMP_CHATBOT_NAME = 'Chatbot'


def run_cf(cmd):
    print('Running cf: %s' % ' '.join(cmd))
    return check_output(cmd)


def get_service_credentials(service_name):
    # Because this runs as a pipeline stage, we don't have access to
    # VCAP_SERVICES,etc. so we need to fish the service credentials out of
    # the environment via cf, which is horrible to parse.
    key = run_cf(
        ['cf', 'service-key', service_name, service_name]).splitlines()
    j = '\n'.join(key[key.index('{'):(key.index('}') + 1)])
    return json.loads(j)


def create_conversation_service(service_name):
    try:
        run_cf(['cf', 'service', service_name])
    except:
        run_cf(['cf', 'create-service', 'conversation', 'free', service_name])
    run_cf(['cf', 'create-service-key', service_name, service_name])
    return get_service_credentials(service_name)


if __name__ == '__main__':
    creds = create_conversation_service('foobar')
    name = os.getenv('CHATBOT_NAME', TMP_CHATBOT_NAME)

    workspace_json = requests.get(
        os.getenv('CHATBOT_JSON_URL', TMP_WORKSPACE)).json()

    conversation_client = ConversationV1(
        username=creds['username'],
        password=creds['password'],
        version='2016-07-11')

    workspace = conversation_client.create_workspace(
        name,
        "%s chatbot workspace" % name,
        workspace_json['language'],
        intents=workspace_json['intents'],
        entities=workspace_json['entities'],
        dialog_nodes=workspace_json['dialog_nodes'],
        counterexamples=workspace_json['counterexamples'],
        metadata=workspace_json['metadata'])

    fmt = 'Created conversation workspace {name} /w ID {workspace_id}'
    print(fmt.format(**workspace))
