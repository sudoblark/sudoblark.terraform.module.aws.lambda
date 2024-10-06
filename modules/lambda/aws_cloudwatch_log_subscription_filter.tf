locals {
  cloudwatch_log_subscription_filter_name = format("%s%s", local.base_lambda_name, "-filter")
}

resource "aws_cloudwatch_log_subscription_filter" "logfilter" {
  count           = var.create_subscription_filter ? 1 : 0
  name            = local.cloudwatch_log_subscription_filter_name
  log_group_name  = module.lambda.lambda_cloudwatch_log_group_name
  filter_pattern  = var.logfilter_pattern
  destination_arn = var.logfilter_destination_arn
}