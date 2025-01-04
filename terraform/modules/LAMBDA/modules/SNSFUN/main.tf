resource "aws_lambda_function" "iam_user_notification" {
  depends_on = [var.iam_permissions_lambda_execution_role,var.s3_s3lam_bucket_lambda_bucket]
  function_name = "IAMUserNotification"
  role          = var.iam_permissions_lambda_execution_role_arn
  handler       = "sns_lambda_function.lambda_handler"
  runtime       = "python3.9"
  filename      = "sns_lambda_function.zip"
  source_code_hash = filebase64sha256("sns_lambda_function.zip")
  s3_bucket     = var.s3_s3lam_bucket_lambda_bucket_name
  s3_key        = "sns_lambda_function.zip"
  tags = {
    "Application" = "FactoryOutlet"
    "Group"       = "Frontend"
  }
  environment {
    variables = {
      SNS_TOPIC_ARN = var.sns_snsuser_sns_topic_user_creation_topic_arn
    }
  }
}
