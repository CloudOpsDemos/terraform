import boto3
import os
import time
import json
import urllib3

from datetime import datetime

SITE                = os.environ['SITE']
BUCKET_NAME         = os.environ['BUCKET_NAME']
EXPECTED            = os.environ['EXPECTED']
SLACK_WEBHOOK_URL   = os.environ['SLACK_WEBHOOK']
SLACK_CHANNEL       = os.environ['SLACK_CHANNEL']

def upload_s3_bucket():
    timestr = time.strftime("%Y%m%d-%H%M%S")
    text = f"We are in the aggregator lambda function, and the date is {timestr}"
    print(f"We are in the aggregator lambda function, and the date is {timestr}")
    encoded_string = text.encode("utf-8")
    bucket_name = os.environ['BUCKET_NAME']
    file_name = f"aggregated_{timestr}.txt"
    s3_path = f"aggregated/{file_name}"
    s3 = boto3.resource('s3')
    s3.Bucket(bucket_name).put_object(Key=s3_path, Body=encoded_string)

def slack_notification(message):
    slack_webhook_url = SLACK_WEBHOOK_URL
    slack_channel = SLACK_CHANNEL
    slack_message = {
        'channel': slack_channel,
        'username': 'Lambda',
        'text': message,
        'icon_emoji': ':aws:',
    }
    headers = {
        'Content-Type': 'application/json'
    }

    http = urllib3.PoolManager()
    response = http.request(
        'POST',
        slack_webhook_url,
        body=json.dumps(slack_message),
        headers=headers
    )
    if response.status_code != 200:
        raise ValueError(
            'Request to slack returned an error %s, the response is:\n%s'
            % (response.status_code, response.text)
        )
    print('Slack notification sent!')

def lambda_handler(event, context):
    print('Checking {} at {}...'.format(SITE, event['time']))
    print(event['id'])

    upload_s3_bucket()
    slack_notification(event['id'])
