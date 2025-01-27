# CALLING THE SNSUSER MODULE

module "SNSUSER" {
  source = "./modules/SNSUSER"
  iam_resources_user_factory_outlet_frontend_developer = var.sns_iam_resources_user_factory_outlet_frontend_developer
}
