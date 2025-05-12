module "label_notify_slack" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  context = module.label.context
  name    = "notify-slack"
}

module "notify_slack" {
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "6.6.0"

  sns_topic_name               = module.label_notify_slack.id
  iam_role_name_prefix         = module.label_notify_slack.id
  lambda_function_name         = module.label_notify_slack.id
  sns_topic_feedback_role_name = module.label_notify_slack.id
  slack_webhook_url            = var.slack_webhook_url
  slack_channel                = "notifications"
  slack_username               = "reporter"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = module.notify_slack.slack_topic_arn
  protocol  = "email"
  endpoint  = var.sns_email_endpoint
}