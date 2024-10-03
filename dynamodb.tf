resource "aws_dynamodb_table" "cache" {
  name         = "udisk-management"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "UserHash"

  attribute {
    name = "UserHash"
    type = "S"
  }
}