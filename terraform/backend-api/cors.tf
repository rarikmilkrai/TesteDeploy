# CORS configuration for API Gateway

#Configurar OPTIONS para os metódos do meus recursos
#Criar integração MOCK para o método OPTIONS
#Configurar método de resposta para OPTIONS
#Configurar integração de resposta para OPTIONS


# OPTIONS method for read resource
resource "aws_api_gateway_method" "options_read" {
  rest_api_id   = aws_api_gateway_rest_api.test_api.id
  resource_id   = aws_api_gateway_resource.read.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# OPTIONS method for update resource
resource "aws_api_gateway_method" "options_update" {
  rest_api_id   = aws_api_gateway_rest_api.test_api.id
  resource_id   = aws_api_gateway_resource.update.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Mock integration for OPTIONS method (read)
resource "aws_api_gateway_integration" "options_integration_read" {
  rest_api_id = aws_api_gateway_rest_api.test_api.id
  resource_id = aws_api_gateway_resource.read.id
  http_method = aws_api_gateway_method.options_read.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Mock integration for OPTIONS method (update)
resource "aws_api_gateway_integration" "options_integration_update" {
  rest_api_id = aws_api_gateway_rest_api.test_api.id
  resource_id = aws_api_gateway_resource.update.id
  http_method = aws_api_gateway_method.options_update.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Method response for OPTIONS (read)
resource "aws_api_gateway_method_response" "options_response_read" {
  rest_api_id = aws_api_gateway_rest_api.test_api.id
  resource_id = aws_api_gateway_resource.read.id
  http_method = aws_api_gateway_method.options_read.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# Method response for OPTIONS (update)
resource "aws_api_gateway_method_response" "options_response_update" {
  rest_api_id = aws_api_gateway_rest_api.test_api.id
  resource_id = aws_api_gateway_resource.update.id
  http_method = aws_api_gateway_method.options_update.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# Integration response for OPTIONS (read)
resource "aws_api_gateway_integration_response" "options_integration_response_read" {
  rest_api_id = aws_api_gateway_rest_api.test_api.id
  resource_id = aws_api_gateway_resource.read.id
  http_method = aws_api_gateway_method.options_read.http_method
  status_code = aws_api_gateway_method_response.options_response_read.status_code
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'https://www.umamicloudchallenge.org'"
  }
}

# Integration response for OPTIONS (update)
resource "aws_api_gateway_integration_response" "options_integration_response_update" {
  rest_api_id = aws_api_gateway_rest_api.test_api.id
  resource_id = aws_api_gateway_resource.update.id
  http_method = aws_api_gateway_method.options_update.http_method
  status_code = aws_api_gateway_method_response.options_response_update.status_code
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'https://www.umamicloudchallenge.org'"
  }
}

# Add CORS headers to POST method responses (read)
resource "aws_api_gateway_method_response" "post_method_response_read" {
  rest_api_id = aws_api_gateway_rest_api.test_api.id
  resource_id = aws_api_gateway_resource.read.id
  http_method = aws_api_gateway_method.post_get.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

# Add CORS headers to POST method responses (update)
resource "aws_api_gateway_method_response" "post_method_response_update" {
  rest_api_id = aws_api_gateway_rest_api.test_api.id
  resource_id = aws_api_gateway_resource.update.id
  http_method = aws_api_gateway_method.post_update.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}