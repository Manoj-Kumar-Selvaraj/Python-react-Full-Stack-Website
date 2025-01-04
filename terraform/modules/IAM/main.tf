# CALLING RESOURCE MODULE

module "RESOURCES" {
  source = "./modules/RESOURCES"
  providers = {
    aws = aws.Root
  }
}

# CALLING RESOURCE MODULE

module "PERMISSIONS" {
  source = "./modules/PERMISSIONS"
  snsuser_sns_topic = var.iam_sns_snsuser_sns_topic
  snsuser_sns_topic_arn = var.iam_sns_snsuser_sns_topic_arn
  providers = {
    aws = aws.Root
  }
}
