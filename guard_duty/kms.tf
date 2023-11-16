# KMS key to encrypt Guard Duty findings in the S3 bucket
resource "aws_kms_key" "guard_duty_key" {
  description             = "GuardDuty findings S3 encryption key"
  deletion_window_in_days = 14
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.guard_duty_key_policy.json
}

# Guard Duty findings bucket KMS key policy
data "aws_iam_policy_document" "guard_duty_key_policy" {
  statement {
    sid = "Allow all KMS Permissions for root account of GD Admin"
    actions = [
      "kms:*"
    ]

    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid    = "Allow the bucket to use the key for encrpytion/decryption"
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

  statement {
    sid = "Allow use of the key for guardduty"
    actions = [
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:DescribeKey"
    ]

    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }
  }

  statement {
    sid = "Allow attachment of persistent resources for guardduty"
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]

    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["guardduty.amazonaws.com"]
    }

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"

      values = [
        "true"
      ]
    }
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
}