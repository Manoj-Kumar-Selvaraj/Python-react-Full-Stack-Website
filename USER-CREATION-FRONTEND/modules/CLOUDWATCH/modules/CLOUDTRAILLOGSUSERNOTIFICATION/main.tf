resource "aws_cloudwatch_log_group" "Cloudtrail_log_group" {
  name              = var.cloudtraillogsusernotification_log_group_name
  retention_in_days = var.cloudtraillogsusernotification_retention_days
}

