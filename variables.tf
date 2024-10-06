# Input variable definitions
variable "environment" {
  description = "Which environment this is being instantiated in."
  type        = string
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Must be either dev, test or prod"
  }
}

variable "application_name" {
  description = "Name of the application utilising resource."
  type        = string
}

variable "raw_lambdas" {
  description = <<EOF

Data structure
---------------
A list of dictionaries, where each dictionary has the following attributes:

REQUIRED
---------
- name                  : The friendly name of for the lambda
- description           : A human-friendly description of the lambda
- iam_policy_statements : A list of dictionaries where each dictionary is an IAM statement defining lambda permissions
-- Each dictionary in this list must define the following attributes:
--- sid: Friendly name for the policy, no spaces or special characters allowed
--- actions: A list of IAM actions the lambda is allowed to perform
--- resources: Which resource(s) the lambda may perform the above actions against
--- conditions    : An OPTIONAL list of dictionaries, which each defines:
---- test         : Test condition for limiting the action
---- variable     : Value to test
---- values       : A list of strings, denoting what to test for

MUTUALLY_EXCLUSIVE
---------
There are a few flavours of lambdas supported, but they are mutually exclusive.
You can have both in the same collection, but you can't have both for the same lambda.
i.e. you can have one dictionary for ZIP and one for containers, but not ZIP and container
information in the same lambda

For ZIP based lambdas, the following arguments are needed:
- source_folder         : Which folder under "application" where the zipped lambda (created via pipelines) lives
- handler               : file.function reference for the lambda handler, i.e. its entrypoint

For container based lambdas, the following arguments are needed:
- image_uri             : URI of the image to utilise
- image_tag             : Version of image to use, defaults to "latest"

OPTIONAL
---------
- environment_variables : A dictionary of env vars to mount for the lambda at runtime, defaults to an empty dictionary
- runtime               : Runtime version to utilise for lambda, defaults to python3.9
- timeout               : Timeout (in seconds) for the lambda, defaults to 900
- memory                : MBs of memory lambda should be allocated, defaults to 512
- security_group_ids    : IDs of security groups the lambda should utilise
- lambda_subnet_ids     : Private IPs which the lambda may utilise for runtime
- storage               : MBs of storage lambda should be allocated, defaults to 512
- common_lambda_layers  : ARNs of lambda layers to include.
- destination_on_failure: ARN of resource to notify when an invocation fails.

EOF
  type = list(
    object({
      source_folder        = optional(string, null),
      image_uri            = optional(string, null),
      image_tag            = optional(string, "latest"),
      name                 = string,
      description          = string,
      handler              = optional(string, null),
      security_group_ids   = optional(list(string)),
      lambda_subnet_ids    = optional(list(string)),
      common_lambda_layers = optional(list(string), []),
      iam_policy_statements = list(
        object({
          sid       = string,
          actions   = list(string),
          resources = list(string),
          conditions = optional(list(
            object({
              test : string,
              variable : string,
              values = list(string)
            })
          ), [])
        })
      ),
      environment_variables  = optional(map(string), {}),
      runtime                = optional(string, "python3.9"),
      timeout                = optional(string, "900"),
      memory                 = optional(string, "512"),
      storage                = optional(string, "512")
      destination_on_failure = optional(string, null)
    })
  )
  validation {
    condition = alltrue([
      for lambda in var.raw_lambdas :
      (
        (tonumber(lambda.timeout) >= 0) &&
        (tonumber(lambda.memory) >= 0) &&
        (tonumber(lambda.storage) >= 0)
      )
    ])
    error_message = "timeout, memory and storage attributes for each lambda should be a valid integer greater than or equal to 0"
  }
  validation {
    condition = alltrue([
      for lambda in var.raw_lambdas :
      !(
        (lambda.source_folder != null) &&
        (lambda.image_uri != null)
      )
    ])
    error_message = "'source_folder' and 'image_uri' for each lambda are mutually exclusive"
  }
  validation {
    condition = alltrue([
      for lambda in var.raw_lambdas :
      !(
        (lambda.source_folder == null) &&
        (lambda.image_uri == null)
      )
    ])
    error_message = "Each lambda must define either 'source_folder' or 'image_uri'"
  }
  validation {
    condition = alltrue([
      for lambda in var.raw_lambdas : alltrue([
        (lambda.source_folder != null ? lambda.handler != null : true)
      ])
    ])
    error_message = "If using 'source_folder', then a lambda must also define 'handler'"
  }
  validation {
    condition = alltrue([
      for lambda in var.raw_lambdas :
      !(
        (lambda.image_uri != null) &&
        (lambda.handler != null)
      )
    ])
    error_message = "If using 'image_uri', then 'handler' is not allowed"
  }
  validation {
    condition = alltrue([
      for lambda in var.raw_lambdas : can(regex("^python[0-9]+.[0-9]+$", lambda.runtime))
    ])
    error_message = "runtime attribute for each lambda must be of form 'python[0-9].[0-9]'"
  }
}