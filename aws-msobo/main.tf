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

# backend
resource "aws_s3_bucket"  "msobo_terraform" {
  bucket = "msobo-terraform"
  tags = {
    Name = "msobo-terraform"
  }
}

resource "aws_s3_bucket_versioning" "msobo_terraform" {
  bucket = aws_s3_bucket.msobo_terraform.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "msobo_terraform_state_lock1" {
  name = "msobo-terraform-state-lock"
  read_capacity = 2
  write_capacity = 1
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name = "msobo-terraform"
  }
}
