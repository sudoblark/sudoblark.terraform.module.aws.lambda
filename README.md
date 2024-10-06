# sudoblark.terraform.module.aws.lambda
Terraform module to create N number of lambdas from ZIPs or URIs. - repo managed by sudoblark.terraform.github

## Developer documentation
The below documentation is intended to assist a developer with interacting with the Terraform module in order to add,
remove or update functionality.

### Pre-requisites
* terraform_docs

```sh
brew install terraform_docs
```

* tfenv
```sh
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bash_profile
```

* Virtual environment with pre-commit installed

```sh
python3 -m venv venv
source venv/bin/activate
pip install pre-commit
```
### Pre-commit hooks
This repository utilises pre-commit in order to ensure a base level of quality on every commit. The hooks
may be installed as follows:

```sh
source venv/bin/activate
pip install pre-commit
pre-commit install
pre-commit run --all-files
```

# Module documentation
The below documentation is intended to assist users in utilising the module, the main thing to note is the
[data structure](#data-structure) section which outlines the interface by which users are expected to interact with
the module itself, and the [examples](#examples) section which has examples of how to utilise the module.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.61.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.70.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lambdas"></a> [lambdas](#module\_lambdas) | ./modules/lambda | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.attached_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Name of the application utilising resource. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Which environment this is being instantiated in. | `string` | n/a | yes |
| <a name="input_raw_lambdas"></a> [raw\_lambdas](#input\_raw\_lambdas) | Data structure<br>---------------<br>A list of dictionaries, where each dictionary has the following attributes:<br><br>REQUIRED<br>---------<br>- name                  : The friendly name of for the lambda<br>- description           : A human-friendly description of the lambda<br>- iam\_policy\_statements : A list of dictionaries where each dictionary is an IAM statement defining lambda permissions<br>-- Each dictionary in this list must define the following attributes:<br>--- sid: Friendly name for the policy, no spaces or special characters allowed<br>--- actions: A list of IAM actions the lambda is allowed to perform<br>--- resources: Which resource(s) the lambda may perform the above actions against<br>--- conditions    : An OPTIONAL list of dictionaries, which each defines:<br>---- test         : Test condition for limiting the action<br>---- variable     : Value to test<br>---- values       : A list of strings, denoting what to test for<br><br>MUTUALLY\_EXCLUSIVE<br>---------<br>There are a few flavours of lambdas supported, but they are mutually exclusive.<br>You can have both in the same collection, but you can't have both for the same lambda.<br>i.e. you can have one dictionary for ZIP and one for containers, but not ZIP and container<br>information in the same lambda<br><br>For ZIP based lambdas, the following arguments are needed:<br>- source\_folder         : Which folder under "application" where the zipped lambda (created via pipelines) lives<br>- handler               : file.function reference for the lambda handler, i.e. its entrypoint<br><br>For container based lambdas, the following arguments are needed:<br>- image\_uri             : URI of the image to utilise<br><br>Note that for container based lambdas, we ignore the tag/version as promotion to usage is intended via pipelines<br>rather than Terraform<br><br>OPTIONAL<br>---------<br>- environment\_variables : A dictionary of env vars to mount for the lambda at runtime, defaults to an empty dictionary<br>- runtime               : Runtime version to utilise for lambda, defaults to python3.9<br>- timeout               : Timeout (in seconds) for the lambda, defaults to 900<br>- memory                : MBs of memory lambda should be allocated, defaults to 512<br>- security\_group\_ids    : IDs of security groups the lambda should utilise<br>- lambda\_subnet\_ids     : Private IPs which the lambda may utilise for runtime<br>- storage               : MBs of storage lambda should be allocated, defaults to 512<br>- common\_lambda\_layers  : ARNs of lambda layers to include.<br>- destination\_on\_failure: ARN of resource to notify when an invocation fails. | <pre>list(<br>    object({<br>      source_folder        = optional(string, null),<br>      image_uri            = optional(string, null),<br>      name                 = string,<br>      description          = string,<br>      handler              = optional(string, null),<br>      security_group_ids   = optional(list(string)),<br>      lambda_subnet_ids    = optional(list(string)),<br>      common_lambda_layers = optional(list(string), []),<br>      iam_policy_statements = list(<br>        object({<br>          sid       = string,<br>          actions   = list(string),<br>          resources = list(string),<br>          conditions = optional(list(<br>            object({<br>              test : string,<br>              variable : string,<br>              values = list(string)<br>            })<br>          ), [])<br>        })<br>      ),<br>      environment_variables  = optional(map(string), {}),<br>      runtime                = optional(string, "python3.9"),<br>      timeout                = optional(string, "900"),<br>      memory                 = optional(string, "512"),<br>      storage                = optional(string, "512")<br>      destination_on_failure = optional(string, null)<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | VPC\_ID of the AWS account this is being instantiated in. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Data structure
```
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

Note that for container based lambdas, we ignore the tag/version as promotion to usage is intended via pipelines
rather than Terraform

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
```
## Examples
See `examples` folder for an example setup.
