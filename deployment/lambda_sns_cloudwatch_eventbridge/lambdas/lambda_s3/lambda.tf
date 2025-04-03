resource "aws_iam_role" "aggregator" {
  name               = "${local.prefix_env}-aggregator"
  assume_role_policy = file("policies/lambda_assume_role_policy.json")
}

resource "aws_iam_policy" "aggregator" {
  name        = "${local.prefix_env}-aggregator"
  description = "Policy to allow Lambda to access S3"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "ExampleStmt",
        "Action" : [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
        ],
        "Effect" : "Allow",
        "Resource" : [
          "${aws_s3_bucket.trigger.arn}",
          "${aws_s3_bucket.trigger.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "aggregator" {
  role       = aws_iam_role.aggregator.name
  policy_arn = aws_iam_policy.aggregator.arn
}

resource "aws_lambda_function" "aggregator" {
  function_name = "${local.prefix_env}-aggregator"
  role          = aws_iam_role.aggregator.arn
  handler       = "aggregator.lambda_handler"
  runtime       = "python3.12"
  filename      = "./lambda_functions/aggregator.zip"
  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.aggregator.bucket
    }
  }
}

resource "aws_lambda_permission" "trigger" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.aggregator.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.trigger.arn
}

resource "aws_s3_bucket_notification" "trigger" {
  bucket = aws_s3_bucket.trigger.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.aggregator.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.trigger]
}
