
output "main_cloudwatch_cloudtrailusernotification_cloudtrail_cloudtrailusernotification_log_group_name" {
    value =  length(module.CLOUDTRAILLOGSUSERNOTIFICATION) > 0 ? module.CLOUDTRAILLOGSUSERNOTIFICATION[0].cloudwatch_cloudtrailusernotification_cloudtrail_cloudtrailusernotification_log_group_name:null
}

output "main_cloudwatch_cloudtrailusernotification_cloudtrail_cloudtrailusernotification_log_group_arn" {
    value =  length(module.CLOUDTRAILLOGSUSERNOTIFICATION) > 0 ? module.CLOUDTRAILLOGSUSERNOTIFICATION[0].cloudwatch_cloudtrailusernotification_cloudtrail_cloudtrailusernotification_log_group_arn:null
}