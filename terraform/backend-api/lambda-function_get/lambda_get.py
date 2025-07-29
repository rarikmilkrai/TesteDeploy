import boto3 # type: ignore
import json

table_name = "count-table"
dynamo = boto3.resource('dynamodb').Table(table_name)

def read(payload):

    return dynamo.get_item(Key=payload['Key'])

operations = {'read': read}

def lambda_handler(event, context):
    try:
        # Check if the request is coming from API Gateway
        if 'body' in event and isinstance(event['body'], str):
            # Parse the body from API Gateway
            body = json.loads(event['body'])
            operation = body['operation']
            payload = body['payload']
        else:
            # Direct Lambda invocation
            operation = event['operation']
            payload = event['payload']

        if operation in operations:
            result = operations[operation](payload)
            return {
                'statusCode': 200,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': 'https://www.umamicloudchallenge.org',
                    'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                    'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'                
                    },
                'body': json.dumps(result, default=str)
            }
        else:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': 'https://www.umamicloudchallenge.org',
                    'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                    'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'  
                },
                'body': json.dumps({'error': f'Unrecognized operation "{operation}"'})
            }

    except Exception as e:
        return {
            'statusCode': 500,
             'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': 'https://www.umamicloudchallenge.org',
                    'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                    'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'  
                },
            'body': json.dumps({'error': str(e)})
        }