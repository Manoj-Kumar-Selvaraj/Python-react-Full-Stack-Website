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
  providers = {
    aws = aws.Root
  }
}

# CALLING SNS MODULE

module "SNS" {
  source = "./modules/SNS"
  depends_on = [module.RESOURCES]
  user = module.RESOURCES.user
  providers = {
    aws = aws.Root
  }
}
