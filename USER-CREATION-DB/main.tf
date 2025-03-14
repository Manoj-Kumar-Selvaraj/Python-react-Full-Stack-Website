terraform {
  backend "s3" {
    bucket         = "factoryoutlet-terraform-lock-bucket"
    key            = "DBRoot/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "factoryoutlet-terraform-lock-table"
  }
}

# IAM Module
module "IAM" {
  source = "./modules/IAM"
  user_name = "FactoryOutletDBDeveloper1"
  group_name = "FactoryOutletDBDevelopers"
  providers = {
    aws = aws.FactoryOutletDBRoot
  }
}
