locals {
  mem_accounts = data.aws_organizations_organization.acme.accounts
  deleg_admin  = var.deleg_admin
  active_accounts = [
    for x in local.mem_accounts :
    x if x.id != local.deleg_admin && x.status == "ACTIVE"
  ]
}