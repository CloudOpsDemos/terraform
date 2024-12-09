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
    key            = "terraform.tfstate"
  }
}

provider "aws" {
  profile = "msobo"
  region  = "us-west-2"
}

# backend
resource "aws_s3_bucket"  "msobo_terraform" {
  bucket = "msobo-terraform"
  tags = {
    Environment = "Terraform"
  }
}

resource "aws_s3_bucket_versioning" "msobo_terraform" {
  bucket = aws_s3_bucket.msobo_terraform.id
  versioning_configuration {
    status = "Enabled"
  }
}
