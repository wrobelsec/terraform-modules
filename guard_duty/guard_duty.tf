module "guard_duty_east_1" {
  source     = "./module"
  depends_on = [aws_s3_bucket.guard_duty_bucket, aws_kms_key.guard_duty_key]

  bucket_arn  = aws_s3_bucket.guard_duty_bucket.arn
  key_arn     = aws_kms_key.guard_duty_key.arn
  deleg_admin = data.aws_caller_identity.current.account_id
}

module "guard_duty_east_2" {
  source     = "./module"
  depends_on = [aws_s3_bucket.guard_duty_bucket, aws_kms_key.guard_duty_key]

  bucket_arn  = aws_s3_bucket.guard_duty_bucket.arn
  key_arn     = aws_kms_key.guard_duty_key.arn
  deleg_admin = data.aws_caller_identity.current.account_id

  providers = {
    aws = aws.us-east-2
  }
}

module "guard_duty_west_1" {
  source     = "./module"
  depends_on = [aws_s3_bucket.guard_duty_bucket, aws_kms_key.guard_duty_key]

  bucket_arn  = aws_s3_bucket.guard_duty_bucket.arn
  key_arn     = aws_kms_key.guard_duty_key.arn
  deleg_admin = data.aws_caller_identity.current.account_id

  providers = {
    aws = aws.us-west-1
  }
}

module "guard_duty_west_2" {
  source     = "./module"
  depends_on = [aws_s3_bucket.guard_duty_bucket, aws_kms_key.guard_duty_key]

  bucket_arn  = aws_s3_bucket.guard_duty_bucket.arn
  key_arn     = aws_kms_key.guard_duty_key.arn
  deleg_admin = data.aws_caller_identity.current.account_id

  providers = {
    aws = aws.us-west-2
  }
}