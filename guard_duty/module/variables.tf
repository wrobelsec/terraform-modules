variable "bucket_arn" {
  description = "The centralized Guard Duty findings bucket"
  type        = string
}

variable "key_arn" {
  description = "The key used to encrypt Guard Duty findings"
  type        = string
}

variable "deleg_admin" {
  description = "The id of the delegated admin account"
  type    = string
}

variable "guard_duty_finding_publishing_frequency" {
  description = "Specifies the frequency of notifications sent for subsequent finding occurrences."
  default     = "SIX_HOURS"
}