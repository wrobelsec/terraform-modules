## state-bucket
Creates a new terraform state bucket backend based on [this guide](https://angelo-malatacca83.medium.com/aws-terraform-s3-and-dynamodb-backend-3b28431a76c1).

### Example
```hcl
module "state-bucket" {
  source = "github.com/wrobelsec/terraform-modules//state-bucket"

  organization_name = "org"
  environment_name  = "development"
}
```

#### Input Reference
The following input variables are supported:

Name | Description | Type | Default
----------------- | --------- | -------- | -------- 
organization_name  | (Required) The name of the organization. | string | N/A
environment_name | (Required) The name of the enviornment of the account. | string | N/A