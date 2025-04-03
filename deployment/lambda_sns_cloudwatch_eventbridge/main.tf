

locals {
  prefix          = "msobo"
  prefix_env      = "${local.prefix}-${var.env_name}"
  aws_account_id = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}

data "aws_route53_zone" "arbitrick" {
  name = "arbitrick.click"
}

terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      version = ">= 5.93"
      source  = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket         = "msobo-terraform-noeks"
    region         = "us-west-2"
    profile        = "msobo"
    key            = "msobo-terraform.tfstate"
    use_lockfile   = true
  }
}

provider "aws" {
  profile = "msobo"
  region  = "us-west-2"
}