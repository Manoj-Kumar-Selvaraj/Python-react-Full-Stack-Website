resource "aws_cloudtrail" "Master_Trail" {
    name                        = "aws_cloudtrail"
    s3_bucket_name              = var.cloudtrial_cloudtrialusernotification_s3_s3trail_s3_bucket_name
    is_multi_region_trail       = true
    enable_log_file_validation  = true
    include_global_service_events = true

    # Management Events
    event_selector {
        read_write_type           = "All"  # Options: ReadOnly, WriteOnly, All
        include_management_events = true
    }

    # Enable Insights Events
    insight_selector {
        insight_type = "ApiCallRateInsight"  # Enables API call rate anomaly detection
    }

    # Attach Role and Log Group
    cloud_watch_logs_role_arn   = var.cloudtrial_cloudtrialusernotification_iam_permissions_cloud_watch_logs_role_arn
    cloud_watch_logs_group_arn  = "${var.cloudtrial_cloudtrialusernotification_cloudwatch_cloudtrailusernotification_cloud_watch_logs_group_arn}:*"
}
