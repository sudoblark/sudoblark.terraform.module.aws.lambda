locals {
  aws_lambda_permission_function_name = reverse(split(":", var.logfilter_destination_arn))[0]
}

resource "aws_lambda_permission" "lambda_permission" {
  count         = var.create_subscription_filter ? 1 : 0
  function_name = local.aws_lambda_permission_function_name
  principal     = "logs.amazonaws.com"
  action        = "lambda:InvokeFunction"
  source_arn    = "${module.lambda.lambda_cloudwatch_log_group_arn}:*"
}