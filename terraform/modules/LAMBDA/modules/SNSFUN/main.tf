resource "aws_lambda_function" "iam_user_notification" {
  function_name = "IAMUserNotification"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  filename      = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")
  s3_bucket     = aws_s3_bucket.lambda_bucket.bucket
  s3_key        = "lambda_function.zip"
  tags = {
    "Application" = "FactoryOutlet"
    "Group"       = "Frontend"
  }
  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.user_creation_topic.arn
    }
  }
}
