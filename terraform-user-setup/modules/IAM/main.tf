# CALLING RESOURCE MODULE

module "RESOURCES" {
  source = "./modules/RESOURCES"
}

# CALLING RESOURCE MODULE

module "PERMISSIONS" {
  depends_on = [module.RESOURCES]
  source = "./modules/PERMISSIONS"
  snsuser_sns_topic_arn = var.iam_sns_snsuser_sns_topic_arn
}
