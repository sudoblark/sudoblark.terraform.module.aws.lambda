locals {
  known_ecr_images = {
    "example-lambda" : lower(format(
      "%s.dkr.ecr.%s.amazonaws.com/%s-%s-example",
      data.aws_caller_identity.current_account.id,
      data.aws_region.current_region.name,
      var.environment,
      var.application_name
    )),
  }
}

data "aws_vpc" "current" {}

# Get current region
data "aws_region" "current_region" {}

# Retrieve the current AWS Account info
data "aws_caller_identity" "current_account" {}