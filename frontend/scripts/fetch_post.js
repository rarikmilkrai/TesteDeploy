const url = 'https://xcquof1gs4.execute-api.us-east-1.amazonaws.com/GET/DynamoDBOperations'
const update = {
    "operation": "update",
    "payload": {
        "Key": {
            "id": "visitors"
        },
        "UpdateExpression": "SET #num = #num + :inc",
        "ExpressionAttributeNames": {
            "#num": "number"
        },
        "ExpressionAttributeValues": {
            ":inc": 1
        }
    }
}
    
    const options = {
    method: 'POST',
    headers: {
    'Content-Type': 'application/json',
    },
    body: JSON.stringify(update),
    };

fetch(url, options)
    .then(response => response.json())
    .then(data => console.log(data))