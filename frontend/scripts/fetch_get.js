fetch('https://xcquof1gs4.execute-api.us-east-1.amazonaws.com/GET/DynamoDBOperations', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({"operation": "read", "payload": {"Key": {"id": "visitors"}}})
})
.then(response => response.json())
.then(data => {
  console.log(data.Item.number)})
.catch(error => console.error('Error:', error));