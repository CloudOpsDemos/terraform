# AntonPutra URL: https://www.youtube.com/watch?v=ox_HJ8w7FPI

resource "aws_iam_role" "lambda" {
    name               = "${local.prefix_env}-lambda"
    assume_role_policy = file("policies/lambda_assume_role_policy.json")
}

resource "aws_iam_policy" "lambda" {
    name        = "${local.prefix_env}-lambda"
    description = "Policy to allow Lambda to access S3"
    policy      = data.aws_iam_policy_document.lambda.json
}
data "aws_iam_policy_document" "lambda" {
    statement {
        actions = [
            "s3:Get*",
            "s3:Put*",
            "s3:List*",
            "s3:Describe*",
            "s3-object-lambda:Get*",
            "s3-object-lambda:List*"
        ]
        resources = [
            "*"
        ]
    }
    statement {
        actions = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogStreams",
            "logs:PutRetentionPolicy",
            "logs:DescribeLogGroups"
        ]
        resources = [
            "*"
        ]
    }
}

resource "aws_cloudwatch_log_group" "lambda" {
    name              = "/aws/lambda/${local.prefix_env}-aggregate-if-trigger"
    retention_in_days = 1
    tags = {
        Terraform = "true"
    }
}

resource "aws_iam_role_policy_attachment" "lambda" {
    role       = aws_iam_role.lambda.name
    policy_arn = aws_iam_policy.lambda.arn
}

resource "aws_lambda_function" "aggregate-if-trigger" {
    function_name = "${local.prefix_env}-aggregate-if-trigger"
    role          = aws_iam_role.lambda.arn
    handler       = "aggregator.lambda_handler"
    runtime       = "python3.12"
    # filename      = "./lambda_functions/aggregator.zip"
    s3_bucket = aws_s3_bucket.lambda_function.bucket
    s3_key    = aws_s3_object.lambda_function.key

    environment {
        variables = {
            BUCKET_NAME     = aws_s3_bucket.aggregator.bucket
            SITE            = "https://aws.amazon.com/"
            EXPECTED        = "Cloud"
            SLACK_WEBHOOK   = "https://hooks.slack.com/services/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"
            SLACK_CHANNEL   = "#cloudwatch_alarms"
        }
    }
}

data "archive_file" "lambda" {
    type        = "zip"
    source_file = "${path.module}/lambda_functions/aggregator.py"
    output_path = "${path.module}/lambda_functions/aggregator.zip"
}

resource "aws_cloudwatch_event_rule" "trigger" {
    name        = "${local.prefix_env}-trigger"
    description = "Trigger for Lambda function"
    schedule_expression = "rate(1 minute)"
}

resource "aws_lambda_permission" "trigger" {
    statement_id  = "AllowExecutionFromEventBridge"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.aggregate-if-trigger.function_name
    principal     = "events.amazonaws.com"
    source_arn    = aws_cloudwatch_event_rule.trigger.arn
    depends_on = [aws_lambda_function.aggregate-if-trigger]
}

resource "aws_cloudwatch_event_target" "trigger" {
    rule      = aws_cloudwatch_event_rule.trigger.name
    target_id = "trigger"
    arn       = aws_lambda_function.aggregate-if-trigger.arn

    depends_on = [aws_lambda_permission.trigger]
  
}