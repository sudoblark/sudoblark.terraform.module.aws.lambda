terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.61.0"
    }
  }
  required_version = "~> 1.5.0"
}

provider "aws" {
  region = "eu-west-2"
}

module "lambda" {
  source = "github.com/sudoblark/sudoblark.terraform.module.aws.lambda?ref=1.0.0"

  application_name = var.application_name
  environment      = var.environment
  raw_lambdas      = local.raw_lambdas
}
