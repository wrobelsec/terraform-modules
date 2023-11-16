# Guard Duty findings S3 bucket
resource "aws_s3_bucket" "guard_duty_bucket" {
  depends_on = [aws_kms_key.guard_duty_key]
  bucket     = "acme-organization-guardduty-findings"

  lifecycle {
    prevent_destroy = true
  }
}

# This block enables encryption on the Guard Duty bucket using the KMS key.
resource "aws_s3_bucket_server_side_encryption_configuration" "guard_duty_bucket" {
  bucket = aws_s3_bucket.guard_duty_bucket.id

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.guard_duty_key.key_id
      sse_algorithm     = "aws:kms"
    }
  }
}

/*
This block enables versioning on files in the Guard Duty bucket.
*/
resource "aws_s3_bucket_versioning" "guard_duty_bucket" {
  bucket = aws_s3_bucket.guard_duty_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# This block restricts public access to the bucket.
resource "aws_s3_bucket_public_access_block" "guard_duty_bucket" {
  bucket = aws_s3_bucket.guard_duty_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

/*
This block creates the lifecycle rules for the logs in the Guard Duty bucket.
After 30 days, logs are changed to the infrequent access tier and after 90 days,
moved to the glacier tier. After one year, logs are deleted from the bucket.
https://aws.amazon.com/s3/storage-classes/
https://aws.amazon.com/s3/pricing/
*/
resource "aws_s3_bucket_lifecycle_configuration" "guard_duty_bucket" {
  bucket = aws_s3_bucket.guard_duty_bucket.id

  rule {
    id = "archive_and_delete"

    expiration {
      days = 365
    }

    filter {
      and {
        prefix = "AWSLogs/"

        tags = {
          rule      = "log"
          autoclean = "true"
        }
      }
    }

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
}

resource "aws_s3_bucket_policy" "guard_duty_bucket_policy" {
  bucket = aws_s3_bucket.guard_duty_bucket.id
  policy = data.aws_iam_policy_document.guard_duty_bucket_policy.json
}

# GD Findings Bucket policy
data "aws_iam_policy_document" "guard_duty_bucket_policy" {
  statement {
    sid = "Allow PutObject"
    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.guard_duty_bucket.arn}/*"
    ]

    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }
  }

  statement {
    sid = "AWSBucketPermissionsCheck"
    actions = [
      "s3:GetBucketLocation",
      "s3:GetBucketAcl",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.guard_duty_bucket.arn
    ]

    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }
  }
  statement {
    sid    = "Deny non-HTTPS access"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:*"
    ]
    resources = [
      "${aws_s3_bucket.guard_duty_bucket.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = [
        "false"
      ]
    }
  }

  statement {
    sid    = "Access logs ACL check"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl"
    ]
    resources = [
      aws_s3_bucket.guard_duty_bucket.arn
    ]
  }

  statement {
    sid    = "Access logs write"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      aws_s3_bucket.guard_duty_bucket.arn,
      "${aws_s3_bucket.guard_duty_bucket.arn}/AWSLogs/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control"
      ]
    }
  }
}