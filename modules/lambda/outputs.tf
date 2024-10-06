output "arn" {
  value = module.lambda.lambda_function_arn
}

output "qualified_arn" {
  value = module.lambda.lambda_function_qualified_arn
}

output "name" {
  value = module.lambda.lambda_function_name
}