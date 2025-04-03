resource "aws_s3_bucket" "aggregator" {
  bucket = "${local.prefix_env}-aggregator"
  tags = {
    Terraform = "true"
  }
}

resource "aws_s3_bucket" "lambda_function" {
  bucket = "${local.prefix_env}-lambda-function"
  tags = {
    Terraform = "true"
  }
}

resource "aws_s3_object" "lambda_function" {
  bucket = aws_s3_bucket.lambda_function.bucket
  key    = "aggregator.zip"
  source = "lambda_functions/aggregator.zip"
  etag   = filemd5("lambda_functions/aggregator.zip")
  tags = {
    Terraform = "true"
  }
}