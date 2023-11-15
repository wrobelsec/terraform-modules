output "tf_state_s3_arn" {
  value = aws_s3_bucket.state_bucket.arn
}

output "state_lock_table" {
  value = aws_dynamodb_table.terraform_lock.id
}