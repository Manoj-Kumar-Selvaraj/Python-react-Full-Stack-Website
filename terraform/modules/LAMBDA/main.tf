# CALLING SNSFUN MODULE

module "RESOURCES" {
  source = "./modules/SNSFUN"
  iam_permissions_lambda_execution_role = var.iam_permissions_lambda_execution_role
  iam_permissions_lambda_execution_role_arn = var.iam_permissions_lambda_execution_role_arn
  s3_s3lam_bucket_lambda_bucket = var.s3_s3lam_bucket_lambda_bucket
  s3_s3lam_bucket_lambda_bucket_name = var.s3_s3lam_bucket_lambda_bucket_name
  providers = {
    aws = aws.Root
  }
}
