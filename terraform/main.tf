# IAM Module
module "IAM" {
  source = "./modules/IAM"

  providers = {
    aws = aws.default
  }
}

# CICD Module
/*module "CICD" {
  source = "./modules/cicd"
  code_pipeline_role = module.IAM.code_pipeline_role
  code_build_role    = module.IAM.code_build_role
  providers = {
    aws = aws.default
  }
}
*/
