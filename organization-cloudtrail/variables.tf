# The name of the cloudtrail and bucket used to store logs.
variable "trail_name" {
  type    = string
  default = "acme-organization-cloudtrail-logs"
}