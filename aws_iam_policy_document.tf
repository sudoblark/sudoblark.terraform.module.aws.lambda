locals {
  barebones_lambda_statements = [
    {
      "sid" : "RequiredEC2BasicPermissions"
      "actions" : [
        "ec2:DescribeInstances",
        "ec2:CreateNetworkInterface",
        "ec2:AttachNetworkInterface",
        "ec2:DeleteNetworkInterface"
      ]
      "resources" = [
        "arn:aws:ec2:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_account.account_id}:*"
      ]
      conditions = []
    },
    {
      "sid" : "RequiredEC2NetworkInterfacePermissions"
      "actions" : [
        "ec2:DescribeNetworkInterfaces"
      ]
      resources = [
        "*"
      ]
      conditions = []
    }
  ]

  actual_iam_policy_documents = {
    for lambda in var.raw_lambdas :
    lambda.name => {
      statements = concat(lambda.iam_policy_statements, local.barebones_lambda_statements)
    }
  }
}

data "aws_iam_policy_document" "attached_policies" {
  for_each = local.actual_iam_policy_documents

  dynamic "statement" {
    for_each = each.value["statements"]

    content {
      sid       = statement.value["sid"]
      actions   = statement.value["actions"]
      resources = statement.value["resources"]

      dynamic "condition" {
        for_each = statement.value["conditions"]

        content {
          test     = condition.value["test"]
          variable = condition.value["variable"]
          values   = condition.value["values"]
        }
      }

    }
  }
}
