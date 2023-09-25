variable "account_alias" {
  description = "The common name for your account. Will replace signin page: https://{account_alias}.signin.aws.amazon.com/console/"
  type        = string
}

variable "minimum_password_length" {
  description = "The minimum password length for the account"
  type        = number
  default     = 16
}

variable "budget_alert_emails" {
  description = "The emails to notify when going over daily/monthly budgets"
  type        = list(string)
}

variable "daily_limit" {
  description = "The daily limit in USD"
  type        = number
  default     = 1
}

variable "monthly_limit" {
  description = "The monthly limit in USD"
  type        = number
  default     = 15
}