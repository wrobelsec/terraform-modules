# This KMS key is used to encrypt the cloudtrail bucket, which is best practice.
resource "aws_kms_key" "cloudtrail_key" {
  description              = "This key is used to encrypt bucket objects"
  deletion_window_in_days  = 14
  enable_key_rotation      = true
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  key_usage                = "ENCRYPT_DECRYPT"
}

# This block applies the key policy to the KMS key.
resource "aws_kms_key_policy" "cloudtrail_key_policy" {
  key_id = aws_kms_key.cloudtrail_key.id
  policy = data.aws_iam_policy_document.cloudtrail_key_policy.json
}

/*
This KMS key policy allows key permissions to be granted through IAM policies rather than
the key policy. It also grants the terraform user rights to create/modify/delete the key.
Finally, it allows the cloudtrail bucket to use this key for encryption/decryption tasks.
*/
data "aws_iam_policy_document" "cloudtrail_key_policy" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions = [
      "kms:*"
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid    = "Allow access for Terraform user"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.arn]
    }

    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid    = "Allow the bucket to use the key for encryption/decryption"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = [
      "*",
    ]
  }
}