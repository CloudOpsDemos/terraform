resource "aws_s3_bucket" "bucket" {
  bucket = "${local.prefix_env}-bucket"

  tags = {
    Name        = "${local.prefix_env}-bucket"
    Environment = local.prefix_env
  }
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

locals {
    lifecycle_rules = [
        {
        id     = "log"
        status = "Enabled"
        prefix = "logs/"
        expiration = 30
        },
        {
        id     = "tmp"
        status = "Enabled"
        prefix = "tmp/"
        expiration = 45
        }
    ]
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  dynamic "rule" {
    for_each = local.lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.status

      filter {
        prefix = rule.value.prefix
      }

      expiration {
        days = rule.value.expiration
      }
    }
  }
}