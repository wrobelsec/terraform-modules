variable "account_alias" {
  description = "The common name for your account. Will replace signin page: https://{account_alias}.signin.aws.amazon.com/console/"
  type        = string
}

variable "console_group_name" {
  description = "The name of the console group"
  type        = string
  default     = "${var.account_alias}_console"
}

variable "admin_group_name" {
  description = "The name of the admin group"
  type        = string
  default     = "${var.account_alias}_admin"
}

variable "minimum_password_length" {
  description = "The minimum password length for the account"
  type        = number
  default     = 16
}

variable "users" {
  description = "The default users to create for the instance"
  type        = list(any)
  default = [
    {
      "name" : "${var.account_alias}_admin",
      "groups" : [var.console_group_name, var.admin_group_name]
    },
    {
      "name" : "${var.account_alias}_CI",
      "groups" : [var.admin_group_name]
    }
  ]
}

variable "budget_alert_emails" {
  description = "The emails to notify when going over daily/monthly budgets"
  type        = list(string)
}

variable "daily_limit" {
  description = "The daily limit in dollars"
  type        = number
  default     = 1
}

variable "monthly_limit" {
  description = "The monthly limit in dollars"
  type        = number
  default     = 15
}