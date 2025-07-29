import boto3 # type: ignore
import json

table_name = "count-table"

# Create the DynamoDB resource
dynamo = boto3.resource('dynamodb').Table(table_name)

# Function to update the counter in the database
def update(payload):
    return dynamo.update_item(**{k: payload[k] for k in ['Key', 'UpdateExpression', 
    'ExpressionAttributeNames', 'ExpressionAttributeValues'] if k in payload})

operations = {'update': update}

#Lambda handler that expects a JSON object to trigger the function

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
                    'Access-Control-Allow-Methods': 'POST,OPTIONS'
                },
                'body': json.dumps(result, default=str)
            }
        else:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({'error': f'Unrecognized operation "{operation}"'})
            }

    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({'error': str(e)})
        }