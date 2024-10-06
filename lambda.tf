locals {
  actual_lambdas = {
    for lambda in var.raw_lambdas :
    lambda.name => merge(lambda, {
      local_path  = lambda.source_folder != null ? "${lambda.source_folder}/src/lambda.zip" : null,
      policy_json = data.aws_iam_policy_document.attached_policies[lambda.name].json
    })
  }
}

module "lambdas" {
  source = "./modules/lambda"

  for_each   = local.actual_lambdas
  depends_on = [data.aws_iam_policy_document.attached_policies]

  application_name          = var.application_name
  environment               = var.environment
  lambda_description        = each.value["description"]
  lambda_suffix             = each.value["name"]
  lambda_handler            = each.value["handler"]
  image_uri                 = each.value["image_uri"]
  image_tag                 = each.value["image_tag"]
  lambda_runtime            = each.value["runtime"]
  lambda_local_path         = each.value["local_path"]
  lambda_timeout            = each.value["timeout"]
  lambda_memory             = each.value["memory"]
  lambda_storage            = each.value["storage"]
  lambda_security_group_ids = each.value["security_group_ids"]
  lambda_subnet_ids         = each.value["lambda_subnet_ids"]
  iam_policy_json           = each.value["policy_json"]
  lambda_layer_arns         = each.value["common_lambda_layers"]
  environment_variables     = each.value["environment_variables"]
  destination_on_failure    = each.value["destination_on_failure"]
}