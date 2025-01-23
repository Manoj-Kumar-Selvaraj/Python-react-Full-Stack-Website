variable cloudtraillogsusernotification_log_group_name {
    type=string
    description="This is the name of the cloud watch log group"
}

variable cloudtraillogsusernotification_retention_days {
    type=number
    description="Number of days for log group retention period
}


variable cloudwatch_eventbridgeusernotification_lambda_snsfun_lambdafn_arn {
    type = string
}
variable cloudwatch_eventbridgeusernotification_lambda_snsfun_lambdafn_name {
    type = string
}

