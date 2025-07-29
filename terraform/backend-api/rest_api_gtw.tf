
resource "aws_api_gateway_rest_api" "test_api" {
  name        = "counter_api"
  description = "enable Lambda functions to call DynamoDB from www"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

}


#create the apigw resources

resource "aws_api_gateway_resource" "read" {
  rest_api_id = aws_api_gateway_rest_api.test_api.id
  parent_id   = aws_api_gateway_rest_api.test_api.root_resource_id
  path_part   = "read"

}

resource "aws_api_gateway_resource" "update" {
  rest_api_id = aws_api_gateway_rest_api.test_api.id
  parent_id   = aws_api_gateway_rest_api.test_api.root_resource_id
  path_part   = "update"

}

#create the http methods

resource "aws_api_gateway_method" "post_get" {
  rest_api_id   = aws_api_gateway_rest_api.test_api.id
  resource_id   = aws_api_gateway_resource.read.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "post_update" {
  rest_api_id   = aws_api_gateway_rest_api.test_api.id
  resource_id   = aws_api_gateway_resource.update.id
  http_method   = "POST"
  authorization = "NONE"
}


#create the lambda integration

resource "aws_api_gateway_integration" "integration_get" {
  rest_api_id             = aws_api_gateway_rest_api.test_api.id
  resource_id             = aws_api_gateway_resource.read.id
  http_method             = aws_api_gateway_method.post_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_visits.invoke_arn
}

resource "aws_api_gateway_integration" "integration_update" {
  rest_api_id             = aws_api_gateway_rest_api.test_api.id
  resource_id             = aws_api_gateway_resource.update.id
  http_method             = aws_api_gateway_method.post_update.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.update_visits.invoke_arn
}



#To allow API GTW to call Lambda

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_visits.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${var.accountId}:${aws_api_gateway_rest_api.test_api.id}/*"

}

resource "aws_lambda_permission" "apigw_lambda2" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_visits.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${var.accountId}:${aws_api_gateway_rest_api.test_api.id}/*"

}

#create the stage
resource "aws_api_gateway_deployment" "counter" {
  rest_api_id = aws_api_gateway_rest_api.test_api.id

  depends_on = [aws_api_gateway_integration.options_integration_update, aws_api_gateway_integration.options_integration_read]

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.read.id,
      aws_api_gateway_resource.update.id,
      aws_api_gateway_method.post_get.id,
      aws_api_gateway_method.post_update.id,
      aws_api_gateway_integration.integration_get.id,
      aws_api_gateway_integration.integration_update.id,
    ]))
  }
  
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.counter.id
  rest_api_id   = aws_api_gateway_rest_api.test_api.id
  stage_name    = "dev"
}