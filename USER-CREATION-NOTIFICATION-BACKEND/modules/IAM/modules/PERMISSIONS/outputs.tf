output "lambda_snsfun_lambda_execution_role" {
  value = aws_iam_role.lambda_execution_role.id
}

output "lambda_snsfun_lambda_execution_role_arn" {
  value = aws_iam_role.lambda_execution_role.arn
}

output "iam_permissions_cloudtrail_cloudtrailusercreationnotification_cloudwatch_logs_role_arn" {
  value = aws_iam_role.cloudwatch_logs_role.arn
}
