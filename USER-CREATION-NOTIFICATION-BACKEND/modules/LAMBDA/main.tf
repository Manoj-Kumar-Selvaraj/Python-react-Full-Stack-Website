# CALLING SNSFUN MODULE

module "SNSFUN" {
  source = "./modules/SNSFUN"
  iam_permissions_lambda_execution_role = var.lambda_iam_permissions_lambda_execution_role
  iam_permissions_lambda_execution_role_arn = var.lambda_iam_permissions_lambda_execution_role_arn
  s3_s3lam_bucket_lambda_bucket_name = var.lambda_s3_s3lam_bucket_lambda_bucket_name
  sns_snsuser_sns_topic_user_creation_topic_arn = var.lambda_sns_snsuser_sns_topic_user_creation_topic_arn
}
