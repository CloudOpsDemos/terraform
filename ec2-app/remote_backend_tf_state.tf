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
    key            = "ec2-terraform.tfstate"
    dynamodb_table = "ec2-terraform-state-lock"
  }
}
