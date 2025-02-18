locals {
  region              = "us-west-2"
  availability_zones  = ["us-west-2a", "us-west-2b"]
}

terraform {
  required_version    = ">= 1.10.0"
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
  region  = local.region
}
