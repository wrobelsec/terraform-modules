locals {
  console_group_name = "${var.account_alias}_console"
  admin_group_name   = "${var.account_alias}_admin"
  users = [
    {
      "name" : "${var.account_alias}_admin",
      "groups" : [local.console_group_name, local.admin_group_name]
    },
    {
      "name" : "${var.account_alias}_CI",
      "groups" : [local.admin_group_name]
    }
  ]
}