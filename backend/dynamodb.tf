resource "aws_dynamodb_table" "shorturls" {
  hash_key         = "backhalf"
  name             = "shorturls"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  read_capacity    = 1
  write_capacity   = 1

  attribute {
    name = "backhalf"
    type = "S"
  }
}

