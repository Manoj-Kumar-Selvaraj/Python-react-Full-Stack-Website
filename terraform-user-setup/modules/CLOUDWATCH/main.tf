# CALLING CLOUDTRAILLOGSUSERNOTIFICATION

module "CLOUDTRAILLOGSUSERNOTIFICATION" {
    count = var.eventbridge?0:1
    source = "./modules/CLOUDTRAILLOGSUSERNOTIFICATION"
    cloudtraillogsusernotification_log_group_name = var.cloudtraillogsusernotification_log_group_name
    cloudtraillogsusernotification_retention_days = var.cloudtraillogsusernotification_retention_days
}

# CALLING EVENTBRIDGEUSERNOTIFICATION MODULE 

module "EVENTBRIDGEUSERNOTIFICATION" {
    count = var.eventbridge?1:0
    source = "./modules/EVENTBRIDGEUSERNOTIFICATION"
    cloudwatch_eventbridgeusernotification_lambda_snsfun_lambdafn_arn = var.cloudwatch_eventbridgeusernotification_lambda_snsfun_lambdafn_arn
    cloudwatch_eventbridgeusernotification_lambda_snsfun_lambdafn_name = var.cloudwatch_eventbridgeusernotification_lambda_snsfun_lambdafn_name
}




