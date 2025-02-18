# data.aws_caller_identity.current.account_id
# data.aws_caller_identity.current.arn
# data.aws_caller_identity.current.user_id
# data.aws_region.current.name

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      version = "~> 5.80.0"
      source  = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket         = "msobo-terraform"
    region         = "us-west-2"
    profile        = "msobo"
    key            = "msobo-terraform.tfstate"
    dynamodb_table = "msobo-terraform-state-lock"
  }
}

provider "aws" {
  profile = "msobo"
  region  = "us-west-2"
}
