resource "aws_s3_bucket" "aggregator" {
  bucket = "${local.prefix_env}-aggregator"
  tags = {
    Terraform = "true"
  }
}

resource "aws_s3_bucket" "trigger" {
  bucket = "${local.prefix_env}-trigger"
  tags = {
    Terraform = "true"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "aggregator" {
  bucket = aws_s3_bucket.aggregator.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "aggregator" {
  bucket = aws_s3_bucket.aggregator.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}