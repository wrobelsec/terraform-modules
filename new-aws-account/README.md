## new-aws-account
Creates a new AWS account based on [this guide](https://technotrampoline.com/articles/setting-up-a-new-aws-account-with-terraform/).

Make sure to follow the first two steps on setting up the account and creating the terraform state bucket via the API before using this module.

### Example
```hcl
module "new-aws-account" {
  source = "github.com/wrobelsec/terraform-modules//new-aws-account"

  account_alias = "organization_name"
  minimum_password_length = 32
  budget_alert_emails = ["email@example.com"]
}
```

#### Input Reference
The following input variables are supported:

Name | Description | Type | Default
----------------- | --------- | -------- | -------- 
account_alias  | (Required) The alias of the account. | string | N/A
minimum_password_length | (Optional) The minimum password length. | number | 16
budget_alert_emails | (Required) The list of emails to notify when budgets are exceeded. | list | N\A
daily_limit | (Optional) The daily budget limit in USD. | number | 1
monthly_limit | (Optional) The monthly budget limit in USD. | number | 15

Default values will be overriden if they are provided as input variables. Usually variables marked as (Required) does not have default values. Check variables.tf file for more information.
