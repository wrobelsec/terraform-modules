terraform {
  backend "s3" {
    bucket         = "fabi-security-terraform-state"
    key            = "global/guard_duty/terraform-state/terraform.tfstate"
    dynamodb_table = "fabi-security-terraform-state-lock"
    region         = "us-east-1"
    encrypt        = "true"
  }

  required_version = ">= 1.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.25.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  region = "us-east-2"
  alias  = "us-east-2"
}

provider "aws" {
  region = "us-west-1"
  alias  = "us-west-1"
}

provider "aws" {
  region = "us-west-2"
  alias  = "us-west-2"
}