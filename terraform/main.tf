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
  iam_snsuser_sns_topic
  iam_snsuser_sns_topic_arn
  providers = {
    aws = aws.Root
  }
}

# CALLING SNS MODULE

module "SNS" {
  source = "./modules/SNS"
  depends_on = [module.IAM]
  sns_iam_resources_user_factory_outlet_frontend_developer1
  user = module.RESOURCES.user
  providers = {
    aws = aws.Root
  }
}

# CALLING LAMBDA MODULE

module "LAMBDA" {
  source = "./modules/LAMBDA"
  depends_on = [module.IAM,module.SNS,module.S3]
  lambda_iam_permissions_lambda_execution_role = main_lambda_snsfun_lambda_execution_role
  lambda_iam_permissions_lambda_execution_role_arn = main_lambda_snsfun_lambda_execution_role_
  lambda_s3_s3lam_bucket_lambda_bucket = 
  lambda_s3_s3lam_bucket_lambda_bucket_name
  user = module.RESOURCES.user
  providers = {
    aws = aws.Root
  }
}

# CALLING S3 MODULE

module "S3" {
  source = "./modules/S3"
  depends_on = [module.IAM]
  user = module.RESOURCES.user
  providers = {
    aws = aws.Root
  }
}
