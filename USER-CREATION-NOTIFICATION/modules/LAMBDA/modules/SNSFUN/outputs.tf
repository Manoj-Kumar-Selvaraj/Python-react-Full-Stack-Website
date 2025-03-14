output "lambda_snsfun_cloudwatch_eventbridgeusernotification_lambda_fn_iam_user_notification_arn" {
  value = aws_lambda_function.iam_user_notification.arn
}

output "lambda_snsfun_cloudwatch_eventbridgeusernotification_lambda_fn_iam_user_notification_name" {
  value = aws_lambda_function.iam_user_notification.function_name
}
