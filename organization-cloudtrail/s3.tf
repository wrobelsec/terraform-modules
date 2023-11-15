# This block creates the cloudtrail S3 bucket.
resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket     = var.trail_name
  depends_on = [aws_kms_key.cloudtrail_key]

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Environment = "security"
    Terraform   = true
  }
}

# This block disables public access to the cloudtrail bucket.
resource "aws_s3_bucket_public_access_block" "cloudtrail_bucket" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# This block enables versioning of log files placed in the cloudtrail bucket.
resource "aws_s3_bucket_versioning" "cloudtrail_bucket" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# This block enables encryption on the cloudtrail bucket using the created key.
resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_bucket" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id

  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.cloudtrail_key.key_id
      sse_algorithm     = "aws:kms"
    }
  }
}

/*
This block creates the lifecycle rules for the logs in the cloudtrail bucket.
After 30 days, logs are changed to the infrequent access tier and after 90 days,
moved to the glacier tier. After one year, logs are deleted from the bucket.
https://aws.amazon.com/s3/storage-classes/
https://aws.amazon.com/s3/pricing/
*/
resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail_bucket" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id

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

# This block attaches the below policy to the cloudtrail bucket.
resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id
  policy = data.aws_iam_policy_document.cloudtrail_bucket_policy.json
}

/*
This block contains the bucket policy for the cloudtrail logs. It enables the
cloudtrail service to put logs in the bucket and has a backup write policy
in case the cloudtrail is converted back from an organization trail.
https://docs.aws.amazon.com/awscloudtrail/latest/userguide/create-s3-bucket-policy-for-cloudtrail.html#org-trail-bucket-policy
*/
data "aws_iam_policy_document" "cloudtrail_bucket_policy" {
  statement {
    sid       = "AWSCloudTrailAclCheck"
    effect    = "Allow"
    resources = [aws_s3_bucket.cloudtrail_bucket.arn]
    actions   = ["s3:GetBucketAcl"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudtrail:${data.aws_region.current.name}:${data.aws_organizations_organization.acme.master_account_id}:trail/${var.trail_name}"]
    }

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }

  statement {
    sid       = "AWSCloudTrailWrite"
    effect    = "Allow"
    resources = ["${aws_s3_bucket.cloudtrail_bucket.arn}/AWSLogs/${data.aws_organizations_organization.acme.master_account_id}/*"]
    actions   = ["s3:PutObject"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudtrail:${data.aws_region.current.name}:${data.aws_organizations_organization.acme.master_account_id}:trail/${var.trail_name}"]
    }

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }

  statement {
    sid       = "AWSCloudTrailOrganizationWrite"
    effect    = "Allow"
    resources = ["${aws_s3_bucket.cloudtrail_bucket.arn}/AWSLogs/${data.aws_organizations_organization.acme.id}/*"]
    actions   = ["s3:PutObject"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudtrail:${data.aws_region.current.name}:${data.aws_organizations_organization.acme.master_account_id}:trail/${var.trail_name}"]
    }

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}