output "iam_permissions_user_creation_topic" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.user_creation_topic
}

output "iam_permissions_user_creation_topic_arn" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.user_creation_topic.arn
}

output "lambda_permissions_user_creation_topic_arn" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.user_creation_topic.arn
}

