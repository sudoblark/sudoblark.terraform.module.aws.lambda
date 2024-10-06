# Common information

variable "application_name" {
  description = "Name of the application that will be running on this lambda"
  type        = string
}

variable "environment" {
  description = "Which environment this is being instantiated in."
  type        = string
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Must be either dev, test or prod"
  }
}

variable "lambda_suffix" {
  description = "Additional suffix to for the lambda name"
  type        = string
}

variable "resource_tags" {
  description = "Tags on the resource"
  type        = map(string)
  default     = {}
}


# Lambda information
variable "lambda_handler" {
  description = "The main handler of the function"
  type        = string
  default     = null
}

variable "lambda_runtime" {
  description = "The runtime of the code"
  type        = string
  default     = null
}

variable "lambda_timeout" {
  description = "The timeout value for the lambda function"
  type        = string
  default     = "3"
}
variable "lambda_memory" {
  description = "The memory size for the lambda function"
  type        = string
  default     = "128"
}

variable "lambda_local_path" {
  description = "The local file path for the lambda code"
  type        = string
  default     = null
}

variable "lambda_storage" {
  description = "Amount of ephemeral storage (/tmp) in MB your Lambda Function can use at runtime. Valid value between 512 MB to 10,240 MB (10 GB)."
  type        = number
  default     = 512
}

variable "lambda_description" {
  description = "The description of the lambda"
  type        = string
}

variable "lambda_at_edge" {
  description = "Set this to true if using Lambda@Edge, to enable publishing, limit the timeout, and allow edgelambda.amazonaws.com to invoke the function"
  type        = bool
  default     = false
}

variable "lambda_layer_arns" {
  description = "The arns of the lambda layers"
  type        = list(string)
  default     = []
}

variable "s3_existing_package" {
  description = "The S3 bucket object with keys bucket, key, version pointing to an existing zip-file to use"
  type        = map(string)
  default     = null
}


variable "lambda_subnet_ids" {
  description = "List of subnet ids when Lambda Function should run in the VPC. Usually private or intra subnets."
  type        = list(string)
  default     = null
}

variable "lambda_security_group_ids" {
  description = "List of security group ids when Lambda Function should run in the VPC."
  type        = list(string)
  default     = null
}

variable "environment_variables" {
  description = "A map that defines environment variables for the Lambda Function."
  type        = map(string)
  default     = {}
}

variable "ignore_source_code_hash" {
  description = "Whether to ignore changes to the function's source code hash. Set to true if you manage infrastructure and code deployments separately."
  type        = bool
  default     = false
}

variable "attach_network_policy" {
  description = "Controls whether VPC/network policy should be added to IAM role for Lambda Function"
  type        = bool
  default     = false
}

variable "attach_tracing_policy" {
  description = "Controls whether X-Ray tracing policy should be added to IAM role for Lambda Function"
  type        = bool
  default     = false
}

#IAM information

variable "iam_policy_json" {
  description = "the json to create an additional policy"
  type        = string
  default     = null
}

variable "create_subscription_filter" {
  description = "Whether to create subscription filter for Lambda Log Group"
  type        = bool
  default     = false
}

variable "logfilter_pattern" {
  description = "Subscription Filter pattern"
  type        = string
  default     = null
}

variable "logfilter_destination_arn" {
  description = "Log Filter destination ARN"
  type        = string
  default     = ""
}

###### Inputs required for containerised lambda only  ######
variable "image_uri" {
  description = "URI of docker image."
  type        = string
  default     = null
}

variable "image_tag" {
  description = "Version of image_uri to utilise for the container, defaults to latest."
  type        = string
  default     = "latest"
}

###### Inputs required SNS notifications only  ######
variable "destination_on_failure" {
  description = "ARN of resource to notify when an invocation fails."
  type        = string
  default     = null
}
