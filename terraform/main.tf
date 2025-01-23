terraform {
  backend "s3" {
    bucket         = "factoryoutlet-terraform-lock-bucket"
    key            = "Root/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "factoryoutlet-terraform-lock-table"
  }
}

# IAM Module
module "IAM" {
  source = "./modules/IAM"
  # depends_on = [module.SNS]
  # iam_sns_snsuser_sns_topic_arn = module.SNS.main_iam_permissions_user_creation_topic_arn != "" ? module.SNS.main_iam_permissions_user_creation_topic_arn : "*"
  iam_sns_snsuser_sns_topic_arn = "*"  
  providers = {
    aws = aws.Root
  }
}
# CALLING SNS MODULE

module "SNS" {
  depends_on  = [module.IAM]
  source = "./modules/SNS"
  sns_iam_resources_user_factory_outlet_frontend_developer1 = module.IAM.main_sns_snsuser_user_factory_outlet_frontend_developer1
  providers = {
    aws = aws.Root
  }
}


# CALLING S3 MODULE

module "S3" {
  source = "./modules/S3"
  depends_on = [module.IAM]
  providers = {
    aws = aws.Root
  }
}

module "LAMBDA" {
  source = "./modules/LAMBDA"
  depends_on = [module.IAM,module.SNS,module.S3]
  lambda_iam_permissions_lambda_execution_role = module.IAM.main_lambda_snsfun_lambda_execution_role
  lambda_iam_permissions_lambda_execution_role_arn = module.IAM.main_lambda_snsfun_lambda_execution_role_arn
  # lambda_s3_s3lam_bucket_lambda_bucket_name = module.S3.main_lambda_snsfun_s3_lambda_bucket_name
  lambda_s3_s3lam_bucket_lambda_bucket_name = "factoryoutlet-lambda-code-storage"
  lambda_sns_snsuser_sns_topic_user_creation_topic_arn = module.SNS.main_lambda_permissions_user_creation_topic_arn
  providers = {
    aws = aws.Root
  }
}

# CALLING MODULE CLOUDWATCH

module "CLOUDWATCH" {
    source = "./modules/CLOUDWATCH"
    cloudwatch_eventbridgeusernotification_lambda_snsfun_lambdafn_arn = main_lambda_snsfun_cloudwatch_eventbridgeusernotification_lambda_fn_iam_user_notification_arn
    cloudwatch_eventbridgeusernotification_lambda_snsfun_lambdafn_name = main_lambda_snsfun_cloudwatch_eventbridgeusernotification_lambda_fn_iam_user_notification_name
    eventbridge = false
}


# CALLING CLOUDTRAIL MODULE

module "CLOUDTRAILUSERNOTIFICATION" {
    source = "./modules/CLOUDTRAIL"
    cloudtrial_cloudtrialusernotification_cloudwatch_cloudtrailusernotification_cloud_watch_logs_group_arn = var.cloudtrial_cloudtrialusernotification_cloudwatch_cloudtrailusernotification_cloud_watch_logs_group_arn
    cloudtrial_cloudtrialusernotification_iam_permissions_cloud_watch_logs_role_arn = var.cloudtrial_cloudtrialusernotification_iam_permissions_cloud_watch_logs_role_arn
    cloudtrial_cloudtrialusernotification_s3_s3trail_s3_bucket_name = var.cloudtrial_cloudtrialusernotification_s3_s3trail_s3_bucket_name
}

module "CLOUDWATCH" {
    source = "./modules/CLOUDWATCH"
    cloudwatch_eventbridgeusernotification_lambda_snsfun_lambdafn_arn = main_lambda_snsfun_cloudwatch_eventbridgeusernotification_lambda_fn_iam_user_notification_arn
    cloudwatch_eventbridgeusernotification_lambda_snsfun_lambdafn_name = main_lambda_snsfun_cloudwatch_eventbridgeusernotification_lambda_fn_iam_user_notification_name
    eventbridge = true
}
