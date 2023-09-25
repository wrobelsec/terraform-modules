# Data reference for the current AWS caller
data "aws_caller_identity" "current" {}

# Create the account alias
resource "aws_iam_account_alias" "alias" {
  account_alias = var.account_alias
}

# Set the password policy
resource "aws_iam_account_password_policy" "password_policy" {
  minimum_password_length        = var.minimum_password_length
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
}

# Set the MFA policy to enforce
module "enforce_mfa" {
  source                          = "terraform-module/enforce-mfa/aws"
  version                         = "~> 1.1.1"
  policy_name                     = "managed-mfa-enforce"
  account_id                      = data.aws_caller_identity.current.id
  groups                          = [aws_iam_group.console_group.name]
  manage_own_signing_certificates = true
  manage_own_ssh_public_keys      = true
  manage_own_git_credentials      = true
}

# Set the daily budget notification
resource "aws_budgets_budget" "daily_budget" {
  name              = "daily-budget"
  budget_type       = "COST"
  limit_amount      = var.daily_limit
  limit_unit        = "USD"
  time_period_start = "2021-01-01_00:00"
  time_period_end   = "2085-01-01_00:00"
  time_unit         = "DAILY"
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = var.budget_alert_emails
  }
}

# Set the monthly budget notification
resource "aws_budgets_budget" "monthly_budget" {
  name              = "monthly-budget"
  budget_type       = "COST"
  limit_amount      = var.monthly_limit
  limit_unit        = "USD"
  time_period_start = "2021-01-01_00:00"
  time_period_end   = "2085-01-01_00:00"
  time_unit         = "MONTHLY"
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.budget_alert_emails
  }
}