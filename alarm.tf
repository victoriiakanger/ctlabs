module "metric_alarm" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarms-by-multiple-dimensions"
  version = "5.7.1"

  alarm_name          = module.label.id
  alarm_description   = "Errors in ${module.lambda_functions.lambda_get_all_authors_lambda_function_name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 1
  period              = 60
  unit                = "Count"
  treat_missing_data  = "ignore"
  
  namespace   = "AWS/Lambda"
  metric_name = "Errors"
  statistic   = "Sum"

  dimensions = {
    "get_authors" = {
        FunctionName = "${module.lambda_functions.lambda_get_all_authors_lambda_function_name}"
    },
    "get_courses" = {
        FunctionName = "${module.lambda_functions.lambda_get_all_courses_lambda_function_name}"
    },
    "save_course" = {
        FunctionName = "${module.lambda_functions.lambda_save_course_lambda_function_name}"
    },
    "get_course_by_id" = {
        FunctionName = "${module.lambda_functions.lambda_get_course_lambda_function_name}"
    },
    "update_course" = {
        FunctionName = "${module.lambda_functions.lambda_update_course_lambda_function_name}"
    },
    "delte_course" = {
        FunctionName = "${module.lambda_functions.lambda_delete_course_lambda_function_name}"
    },
  }
  alarm_actions = [module.notify_slack.slack_topic_arn]
}