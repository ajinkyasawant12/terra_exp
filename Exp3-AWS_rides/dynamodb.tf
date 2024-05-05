resource "aws_dynamodb_table" "rides" {
  name           = "Rides"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "RideId"
    type = "S"
  }

  hash_key = "RideId"
}

output "dynamodb_table_arn" {
  description = "The ARN of the DynamoDB table"
  value       = aws_dynamodb_table.rides.arn
}