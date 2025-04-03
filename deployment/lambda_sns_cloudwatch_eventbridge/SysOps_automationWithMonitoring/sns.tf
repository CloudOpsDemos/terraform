resource "aws_iam_role" "sns-logs" {
    name               = "${local.prefix_env}-sns-logs"
    assume_role_policy = file("policies/sns_assume_role_policy.json")
}

resource "aws_iam_role_policy_attachment" "sns-logs" {
    role       = aws_iam_role.sns-logs.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSNSRole"
}

resource "aws_sns_topic" "sns-logs" {
    name = "${local.prefix_env}-sns-logs"
    display_name = "${local.prefix_env}-sns-logs"
    tags = {
        Name = "${local.prefix_env}-sns-logs"
    }
}

resource "aws_sns_topic_subscription" "sns-logs" {
    topic_arn = aws_sns_topic.sns-logs.arn
    protocol  = "email"
    endpoint  = "marek.sobolak@gmail.com"
    depends_on = [aws_cloudwatch_metric_alarm.cpu_high]
}
