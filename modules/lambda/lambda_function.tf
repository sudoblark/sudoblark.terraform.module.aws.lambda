locals {
  actual_lambda_name = format("%s%s", local.base_lambda_name, "-lambda")
  /*
    image_uri wrapped in try as not _all_ lambdas may actually define it, and we
    have ternary conditionals below to ensure this is only used when image_uri is not null.

    But, we don't want to define this multiple times. So we define here with a try instead.
  */
  actual_image_url = var.image_uri == null ? null : format("%s:%s", try(var.image_uri, ""), var.image_tag)
}

module "lambda" {
  #checkov:skip=CKV_TF_2:This is versioned, checkov is just dumb and assumes all modules are a git reference rather than a registry reference.
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.2.1"

  function_name          = local.actual_lambda_name
  description            = var.lambda_description
  handler                = var.lambda_handler
  runtime                = var.lambda_runtime
  timeout                = var.lambda_at_edge ? min(var.lambda_timeout, 30) : var.lambda_timeout
  image_uri              = local.actual_image_url
  package_type           = var.image_uri != null ? "Image" : (var.lambda_local_path != null || var.s3_existing_package != null) ? "Zip" : null
  local_existing_package = var.lambda_local_path
  memory_size            = var.lambda_memory
  ephemeral_storage_size = var.lambda_storage
  store_on_s3            = false
  create_package         = false
  create_role            = true

  attach_network_policy = var.attach_network_policy == 1
  attach_tracing_policy = var.attach_tracing_policy == 1
  attach_policy         = true
  attach_policy_json    = var.iam_policy_json

  vpc_security_group_ids  = var.lambda_security_group_ids
  vpc_subnet_ids          = var.lambda_subnet_ids
  environment_variables   = var.environment_variables
  s3_existing_package     = var.s3_existing_package
  ignore_source_code_hash = var.ignore_source_code_hash
  layers                  = var.lambda_layer_arns
  publish                 = var.lambda_at_edge

  destination_on_failure = var.destination_on_failure
  /*
    Looking at
    https://github.com/terraform-aws-modules/terraform-aws-lambda/blob/dc7c19b3f93b059eede1f9d5378793fdb5cfdf70/modules/alias/main.tf#L55
    we can safely hard-code this and it'll support both destination_on_failure being a string and being null,
    whereas if we try to do var.destination_on_failure != null ? true : false we get:

    The "for_each" map includes keys derived from resource attributes that cannot
    be determined until apply, and so Terraform cannot determine the full set of
    keys that will identify the instances of this resource.
  */
  create_async_event_config                 = true
  create_current_version_async_event_config = false

  cloudwatch_logs_retention_in_days = 14
  tags = merge(
    {
      "Name" = local.actual_lambda_name
    },
    var.resource_tags
  )
}