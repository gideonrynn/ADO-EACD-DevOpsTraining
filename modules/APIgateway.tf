

// data source to get the access to the effective Account ID
data "aws_caller_identity" "current" {}

//resource to create API
resource "aws_api_gateway_rest_api" "wrst-apigateway-rest" {
  name        = "WildRydesTAPI"
  description = "This is my API for Wild Rydes with Terraform"

  tags = {
    "app_name" = "${var.app_name}"
    "env"      = "${var.env}"
  }
}

// API resource for /ridescdt - in the tutorial, this is just /ride
resource "aws_api_gateway_resource" "wrst-ag-ride-resource" {
  rest_api_id = aws_api_gateway_rest_api.wrst-apigateway-rest.id
  parent_id   = aws_api_gateway_rest_api.wrst-apigateway-rest.root_resource_id
  path_part   = "ride"
}

// API gateway authorizer that users the cognito user pool created in earlier steps
// had to add [] to provider_arns, as it is expecting an array and not an individual value
resource "aws_api_gateway_authorizer" "wrst-apigateway-authorizer" {
  name                   = "WildRydesTAuthorizer"
  rest_api_id            = aws_api_gateway_rest_api.wrst-apigateway-rest.id
  authorizer_uri         = aws_lambda_function.wrst-lambda.invoke_arn
  authorizer_credentials = aws_iam_role.wrst-iam-lambda-role.arn
  type = "COGNITO_USER_POOLS"
  provider_arns = [aws_cognito_user_pool.wrst-pool.arn]
}

// set up an HTTP Method for /tride api gateway resource for
resource "aws_api_gateway_method" "wrst-apigate-method" {
  rest_api_id   = aws_api_gateway_rest_api.wrst-apigateway-rest.id
  resource_id   = aws_api_gateway_resource.wrst-ag-ride-resource.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.wrst-apigateway-authorizer.id

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

// sets HTTP method response for api gateway resource
resource "aws_api_gateway_method_response" "wrst-ag-method-response" {
  rest_api_id   = aws_api_gateway_rest_api.wrst-apigateway-rest.id
  resource_id   = aws_api_gateway_resource.wrst-ag-ride-resource.id
  http_method = aws_api_gateway_method.wrst-apigate-method.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Max-Age"       = true
  }

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [
    aws_api_gateway_method.wrst-apigate-method
  ]
}

// set integration type and resource for intgration with Lambda function
// AWS_PROXY = Lambda Proxy
resource "aws_api_gateway_integration" "wrst-apigateway-integration" {
  rest_api_id             = aws_api_gateway_rest_api.wrst-apigateway-rest.id
  resource_id             = aws_api_gateway_resource.wrst-ag-ride-resource.id
  http_method             = aws_api_gateway_method.wrst-apigate-method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.wrst-lambda.invoke_arn
}

// sets HTTP Method Integration Response for api gateway
resource "aws_api_gateway_integration_response" "wrst-ag-integration-response" {
  rest_api_id   = aws_api_gateway_rest_api.wrst-apigateway-rest.id
  resource_id   = aws_api_gateway_resource.wrst-ag-ride-resource.id
  http_method = aws_api_gateway_method.wrst-apigate-method.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'${join(",", var.allowed_headers)}'"
    "method.response.header.Access-Control-Allow-Methods" = "'${join(",", var.allowed_methods)}'"
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.allowed_origin}'"
    "method.response.header.Access-Control-Max-Age"       = "'${var.allowed_max_age}'"
  }

  depends_on = [
    aws_api_gateway_integration.wrst-apigateway-integration
  ]
}

// give Amazon API Gateway permission to invoke your function
// review control access for invoking an API https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
// for accountId, use aws-caller identity https://www.terraform.io/docs/providers/aws/d/caller_identity.html
// you can also find the account Id using the AWS CLI for confirmation https://docs.aws.amazon.com/IAM/latest/UserGuide/console_account-alias.html 
resource "aws_lambda_permission" "wrst-lambda-api-permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.wrst-lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.wrst-apigateway-rest.id}/*/${aws_api_gateway_method.wrst-apigate-method.http_method}${aws_api_gateway_resource.wrst-ag-ride-resource.path}"
}

// sets up an API Gateway REST deployment
// update stage name with variable
resource "aws_api_gateway_deployment" "wrst-apigateway-deployment" {
  depends_on = [aws_api_gateway_integration.wrst-apigateway-integration]

  rest_api_id = aws_api_gateway_rest_api.wrst-apigateway-rest.id
  stage_name  = "scd"

  # variables = {
  #   "answer" = "42"
  # }

  lifecycle {
    create_before_destroy = true
  }
}


//** CORS **//

//read AWS: Enabling CORS for a REST API resource: https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-cors.html

// options method is required to enable CORS
// http method attribute cors methods

resource "aws_api_gateway_method" "wrst-ag-method-cors" {
  rest_api_id   = aws_api_gateway_rest_api.wrst-apigateway-rest.id
  resource_id   = aws_api_gateway_resource.wrst-ag-ride-resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "wrst-ag-integration-cors" {
  rest_api_id   = aws_api_gateway_rest_api.wrst-apigateway-rest.id
  resource_id   = aws_api_gateway_resource.wrst-ag-ride-resource.id
  http_method = aws_api_gateway_method.wrst-ag-method-cors.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = <<EOF
      { "statusCode": 200 }
  EOF
  }
}

resource "aws_api_gateway_method_response" "wrst-ag-methodresponse-cors" {
  rest_api_id   = aws_api_gateway_rest_api.wrst-apigateway-rest.id
  resource_id   = aws_api_gateway_resource.wrst-ag-ride-resource.id
  http_method = aws_api_gateway_method.wrst-ag-method-cors.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Max-Age"       = true
  }

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [
    aws_api_gateway_method.wrst-ag-method-cors
  ]
}

// set locals here for response parameters as well
resource "aws_api_gateway_integration_response" "wrst-ag-integrationresponse-cors" {
  rest_api_id   = aws_api_gateway_rest_api.wrst-apigateway-rest.id
  resource_id   = aws_api_gateway_resource.wrst-ag-ride-resource.id
  http_method = aws_api_gateway_method.wrst-ag-method-cors.http_method
  status_code = 200

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'${join(",", var.allowed_headers)}'"
    "method.response.header.Access-Control-Allow-Methods" = "'${join(",", var.allowed_methods)}'"
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.allowed_origin}'"
    "method.response.header.Access-Control-Max-Age"       = "'${var.allowed_max_age}'"
  }

  depends_on = [
    aws_api_gateway_integration.wrst-ag-integration-cors
  ]
}
