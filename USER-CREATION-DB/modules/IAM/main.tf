# CALLING RESOURCE MODULE

module "RESOURCES" {
  source = "./modules/RESOURCES"
  user_name = var.user_name
  group_name = var.group_name
}

# CALLING RESOURCE MODULE
/*
module "PERMISSIONS" {
  # depends_on = [module.RESOURCES]
  source = "./modules/PERMISSIONS"
}
*/
