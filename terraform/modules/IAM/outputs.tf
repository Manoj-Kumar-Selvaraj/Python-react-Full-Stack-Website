output "main_lambda_snsfun_lambda_execution_role" {
  value = module.PERMISSIONS.aws_iam_role.lambda_execution_role
}

output "main_lambda_snsfun_lambda_execution_role_arn" {
  value = module.PERMISSIONS.aws_iam_role.lambda_execution_role.arn
}

output "main_sns_snsuser_user_factory_outlet_frontend_developer1" {
  value = module.RESOURCES.aws_iam_user.factory_outlet_frontend_developer1.name
}

