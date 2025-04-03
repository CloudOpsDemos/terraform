resource "aws_secretsmanager_secret" "slack_app_cw_alerts_token" {
  name = "${local.prefix_env}-slack-app-cw-alerts-token"
  tags = {
    Terraform = "true"
    Group = "allerts"
  }
}

