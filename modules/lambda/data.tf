locals {
  base_lambda_name = lower(format("aws-%s-%s%s", var.environment, var.application_name, var.lambda_suffix))
}