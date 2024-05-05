resource "aws_iam_role" "wildrydes_lambda_role" {
    name = "WildRydesLambda"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "wildrydes_lambda_logs_policy" {
    name       = "WildRydesLambdaLogsPolicy"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
    roles      = [aws_iam_role.wildrydes_lambda_role.name]
}

resource "aws_iam_policy" "wildrydes_lambda_dynamodb_policy" {
    name        = "WildRydesLambdaDynamoDBPolicy"
    description = "Allows the dynamodb:PutItem action for the table"
    policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "dynamodb:PutItem",
            "Resource": "arn:aws:dynamodb:REGION:ACCOUNT_ID:table/TABLE_NAME"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "wildrydes_lambda_dynamodb_attachment" {
    role       = aws_iam_role.wildrydes_lambda_role.name
    policy_arn = aws_iam_policy.wildrydes_lambda_dynamodb_policy.arn
}

resource "aws_lambda_function" "request_unicorn" {
    function_name = "RequestUnicorn"
    role          = aws_iam_role.wildrydes_lambda_role.arn
    runtime       = "nodejs20.x"
    handler       = "requestUnicorn.handler"
    filename      = "${path.module}/requestUnicorn.js"
}