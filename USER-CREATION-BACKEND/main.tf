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
  user_name = "Factory_outlet_frontend_developer1"
  group_name = "FactoryOutletFrontEndDevelopers"
  providers = {
    aws = aws.Root
  }
}
