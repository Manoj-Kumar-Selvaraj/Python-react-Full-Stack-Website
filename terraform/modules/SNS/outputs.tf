output "main_iam_permissions_user_creation_topic" {
  description = "ARN of the SNS topic"
  value       = module.SNSUSER.iam_permissions_user_creation_topic
}

output "main_iam_permissions_user_creation_topic_arn" {
  description = "ARN of the SNS topic"
  value       = module.SNSUSER.iam_permissions_user_creation_topic_arn
}
