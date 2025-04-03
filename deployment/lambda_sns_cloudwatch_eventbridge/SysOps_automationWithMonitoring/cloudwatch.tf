resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name            = "${local.prefix_env}-cpu-high"
  comparison_operator   = "GreaterThanThreshold"
  evaluation_periods    = "2"
  metric_name           = "GroupTotalInstances"
  namespace             = "AWS/AutoScaling"
  period                = "60"
  statistic              = "Average"
  threshold             = "5"

  alarm_description = "This metric monitors autoscaling group total instances"

  alarm_actions = [
    aws_sns_topic.sns-logs.arn
  ]
}