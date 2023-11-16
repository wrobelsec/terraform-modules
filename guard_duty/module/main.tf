# GuardDuty Detector in the Delegated admin account
resource "aws_guardduty_detector" "guard_duty_detector" {
  enable                       = true
  finding_publishing_frequency = var.guard_duty_finding_publishing_frequency
}

# Organization GuardDuty configuration in the Delegated admin account
resource "aws_guardduty_organization_configuration" "guard_duty_detector_org" {
  auto_enable_organization_members = "ALL"
  detector_id                      = aws_guardduty_detector.guard_duty_detector.id

  datasources {
    s3_logs {
      auto_enable = true
    }
    kubernetes {
      audit_logs {
        enable = true
      }
    }
    malware_protection {
      scan_ec2_instance_with_findings {
        ebs_volumes {
          auto_enable = true
        }
      }
    }
  }
}

# Enables monitoring of RDS login events through Guard Duty
resource "aws_guardduty_organization_configuration_feature" "rds_login_events" {
  detector_id = aws_guardduty_detector.guard_duty_detector.id
  name        = "RDS_LOGIN_EVENTS"
  auto_enable = "ALL"
}

# Enables monitoring of Lambda Network Logs through Guard Duty
resource "aws_guardduty_organization_configuration_feature" "lambda_network_logs" {
  detector_id = aws_guardduty_detector.guard_duty_detector.id
  name        = "LAMBDA_NETWORK_LOGS"
  auto_enable = "ALL"
}

# GuardDuty Publishing destination in the Delegated admin account
resource "aws_guardduty_publishing_destination" "guard_duty_detector" {
  detector_id     = aws_guardduty_detector.guard_duty_detector.id
  destination_arn = var.bucket_arn
  kms_key_arn     = var.key_arn
}

# Declares other organization members for Guard Duty
resource "aws_guardduty_member" "guard_duty_members" {
  depends_on  = [aws_guardduty_organization_configuration.guard_duty_detector_org]
  detector_id = aws_guardduty_detector.guard_duty_detector.id
  invite      = true

  count                      = length(local.active_accounts)
  account_id                 = local.active_accounts[count.index].id
  disable_email_notification = true
  email                      = local.active_accounts[count.index].email

  lifecycle {
    ignore_changes = [
      email
    ]
  }
}