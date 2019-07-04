import os
import boto3
import random
import string
import json
from botocore.exceptions import ClientError
import logging

region = os.getenv("AWS_REGION", "no-region")
health = os.getenv("HEALTH", 200)
tablename = os.getenv("TABLE", "no-table")

log = logging.getLogger()
log.setLevel(logging.DEBUG)

dynamodb = boto3.resource('dynamodb', region_name=region)
table = dynamodb.Table(tablename)

def str_random(N=6):
  return ''.join(random.choice(string.ascii_lowercase) for _ in range(N))

def handler(event, context):
  log.debug("Received event in get_item: {}".format(json.dumps(event)))

  basepath = event["path"].split('/')

  # health page
  if basepath[1] == "health":
    if(health == "200"):
      return {
        "statusCode": 200,
        "headers": {
          "Content-Type": "text/html; charset=utf-8"
        },
        "body": "OK from {}".format(region)
      }
    else:
      return {
        "statusCode": 500,
        "headers": {
          "Content-Type": "text/html; charset=utf-8"
        },
        "body": "NOK from {}".format(region)
      }
  
  # create page
  elif basepath[1] == "create":
    target = event['queryStringParameters']['url']
    host = event['headers']['host']
    random_string = str_random()
    table.put_item(
      Item={
        'backhalf': random_string,
        'url': target
      }
    )
    return {
      "statusCode": 200,
      "headers": {
          "Content-Type": "text/html; charset=utf-8"
        },
      "body": "http://{}/{}".format(host, random_string)
    }

  # redirect
  else:
    backhalf = basepath[1]

    try:
      response = table.get_item(
        Key={
          'backhalf': backhalf
        }
      )
      url = response['Item']['url']
      return {
        'statusCode': 301,
        'headers': {
          'Location': url
        }
      }
    except ClientError as e:
      return {
        "statusCode": 500,
        "headers": {
          "Content-Type": "text/html; charset=utf-8"
        },
        "body": "Error: {}".format(e)
      }
