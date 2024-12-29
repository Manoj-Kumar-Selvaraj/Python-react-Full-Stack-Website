#Terraform Import:

resource "aws_iam_group" "factory_outlet" {
  name = "FactoryOutlet"
}

# IAM Module
module "IAM" {
  source = "./modules/IAM"
  group = aws_iam_group.factory_outlet.name
  providers = {
    aws = aws.default
  }
}

# CICD Module
module "CICD" {
  source = "./modules/cicd"
  code_pipeline_role = module.IAM.code_pipeline_role
  code_build_role    = module.IAM.code_build_role
  git_pat = var.git_pat
  Attach_UserEcrPolicy = module.IAM.Attach_UserEcrPolicy
  providers = {
    aws = aws.default
  }
}

