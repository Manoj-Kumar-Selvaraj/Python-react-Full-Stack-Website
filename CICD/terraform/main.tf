
# CALLING MODULE FRONTEND
module "FRONTEND" {
  source = "./modules/FRONTEND"
  code_pipeline_role = "arn:aws:iam::039612868338:role/codepipeline-service-role"
  code_build_role    = "arn:aws:iam::039612868338:role/codebuild-service-role"
  git_pat = var.git_pat
  providers = {
    aws = aws.FRONTENDDEVELOPER1
  }
}