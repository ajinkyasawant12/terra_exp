resource "aws_api_gateway_rest_api" "my_api" {
    name        = "WildRydes"
    description = "API for WildRydes"

    endpoint_configuration {
        types = ["REGIONAL"]
    }
}

resource "aws_cognito_user_pool" "wildrydes" {
  name = "wildrydes"
}

resource "aws_api_gateway_rest_api" "my_api" {
  name        = "WildRydes"
  description = "API for WildRydes"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_authorizer" "wildrydes" {
  name                   = "WildRydes"
  type                   = "COGNITO_USER_POOLS"
  rest_api_id            = aws_api_gateway_rest_api.my_api.id
  provider_arns          = [aws_cognito_user_pool.wildrydes.arn]
  identity_source        = "method.request.header.Authorization"
}

resource "aws_api_gateway_resource" "ride" {
    rest_api_id = aws_api_gateway_rest_api.my_api.id
    parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
    path_part   = "ride"
}

resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.ride.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.wildrydes.id
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.ride.id
  http_method             = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.request_unicorn.invoke_arn
}

resource "aws_api_gateway_method_settings" "authorization_settings" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  stage_name  = "your_stage_name"
  method_path = "${aws_api_gateway_resource.ride.path}/${aws_api_gateway_method.post_method.http_method}"
  settings {
  }
}


resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  stage_name    = "prod"
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on  = [aws_api_gateway_integration.integration]
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  stage_name  = "prod"
  description = "Deployment for the WildRydes API"
  lifecycle {
    create_before_destroy = true
  }
}

output "invoke_url" {
  description = "The URL to invoke the API"
  value       = "https://${aws_api_gateway_rest_api.my_api.id}.execute-api.${var.region}.amazonaws.com/prod"
}