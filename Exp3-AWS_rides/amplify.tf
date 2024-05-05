provider "aws" {
  region = "us-east-1"
}

resource "aws_codecommit_repository" "wild_rydes" {
  repository_name = "wild-rydes"
  description     = "This is the Wild Rydes AWS CodeCommit Repository."
  clone_url_http  = "https://github.com/aws-samples/aws-serverless-webapp-workshop.git"
}

variable "oauth_token" {
  description = "OAuth token used for authentication with the codecommit repository"
  type        = string
}

resource "aws_iam_role" "wildrydes_backend_role" {
  name = "wildrydes-backend-role"
  
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "amplify.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_amplify_app" "wild_rydes" {
  name         = "wild-rydes-app"
  repository   = aws_codecommit_repository.wild_rydes.repository_name
  oauth_token  = var.oauth_token
}

resource "aws_iam_role_policy_attachment" "wildrydes_backend_role_policy_attachment" {
  role       = aws_iam_role.wildrydes_backend_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitReadOnly"
}

resource "aws_amplify_branch" "master" {
  app_id       = aws_amplify_app.wild_rydes.app_id
  branch_name  = "master"
}

resource "aws_amplify_domain" "wild_rydes" {
  domain_name  = "wildrydes.example.com"
  app_id       = aws_amplify_app.wild_rydes.app_id
}

resource "aws_iam_policy_attachment" "wildrydes_backend_role_attachment" {
  name       = "wildrydes-backend-role-attachment"
  roles      = [aws_iam_role.wildrydes_backend_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeCommitReadOnly"
}

output "amplify_app_domain_url" {
  value = aws_amplify_domain.wild_rydes.domain_name
}
