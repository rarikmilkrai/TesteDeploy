
describe("Testing my API", () => {
    it("return data from DDB", () => {
        const read = {"operation": "read", "payload": {"Key": {"id": "visitors"}}}
        
        cy.api({
            url: 'https://0vo0bnqjij.execute-api.us-east-1.amazonaws.com/retrieve/get-visits',
            method: 'POST',
            body: read
        }).then(response => {
            expect(response.status).to.eq(200)
            expect(response.body.Item).to.have.keys('id', 'number')
            expect(response.body.ResponseMetadata.HTTPHeaders).to.have.property("content-type", "application/x-amz-json-1.0")
            
    })
    })
    it("Delete item from DDB", () => {
        const operation = {"operation": "delete", "payload": {"Key": {"id": "visitors"}}}
        cy.api({
            url: 'https://0vo0bnqjij.execute-api.us-east-1.amazonaws.com/update/update-table',
            method: 'POST',
            body: operation
        }).then(response => {
            expect(response.body.errorMessage).to.eq("Unrecognized operation \"delete\"")
        })

    })
    it.only("Check the visitors DOM", () => {
        cy.visit("https://www.umamicloudchallenge.org/")
        cy.get('#visitors').should('exist')
        



    })
    it("Update Dynamo", () => {

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
        };

        cy.api({
            url:'https://0vo0bnqjij.execute-api.us-east-1.amazonaws.com/update/update-table',
            method: 'POST',
            body: update
        }).then(response => {
            expect(response.status).to.eql(200)
            
        })

    })

})