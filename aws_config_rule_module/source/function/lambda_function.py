import boto3
import json
import logging
from datetime import datetime
import requests


"""
This lambda is to receive a payload from aws_config_sns_topic. The payload will be parsed and send
to Slack channel using Slack webhook obtained from AWS Secrets Manager.

Omar A Omar
2/26/2023
"""


HOOK_URL = boto3.client('secretsmanager').get_secret_value(SecretId='slack/sre-notifications')['SecretString']


# get the AWS account number to use in the slack message
account_number = boto3.client('sts').get_caller_identity().get('Account')
logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    logger.info("Event: " + str(event))
    message = json.dumps(event['Records'][0]['Sns']['Message'])


    slack_message = {
        'attachments': [
            {
                'fallback': 'Required plain-text summary of the attachment.',
                'color': '#9036a6',
                'pretext': '*AWS Config Warning (AWS: ' + account_number + ')*\n',
                'text': message,
                'mrkdwn_in': ['text', 'pretext'],
                'footer': 'SRE4',
                'ts':  convert_time_to_ts(get_current_central_timestamp())
            }
        ]
    }

    try:
        response = requests.post(HOOK_URL, data=json.dumps(slack_message), headers={'Content-Type': 'application/json'})
        logger.info('Response: %s', response)
    except Exception as e:
        logger.error('Error: %s', e)
        raise e

    return {
        'statusCode': 200,
        'Message': 'Message sent to Slack'
    }

    
# get the current time and format it
def get_current_central_timestamp():
    now = datetime.now()
    return now.strftime("%H:%M:%S %m-%d-%Y")

# convert time to timestamp
def convert_time_to_ts(get_current_central_timestamp):
    ts = datetime.strptime(get_current_central_timestamp, "%H:%M:%S %m-%d-%Y").timestamp()
    return ts