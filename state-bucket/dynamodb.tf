resource "aws_dynamodb_table" "terraform_lock" {
  name         = "${aws_s3_bucket.state_bucket.id}-lock"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
  lifecycle {
    prevent_destroy = true
  }
}