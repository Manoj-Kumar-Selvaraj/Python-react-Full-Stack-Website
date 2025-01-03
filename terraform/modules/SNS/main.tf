# CALLING THE SNSUSER MODULE

module "SNSUSER" {
  source = "./modules/SNSUSER"
  iam_resources_user_factory_outlet_frontend_developer1 = var.iam_resources_user_factory_outlet_frontend_developer1
  providers = {
    aws = aws.Root
  }
}
