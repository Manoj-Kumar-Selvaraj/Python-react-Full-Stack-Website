# CALLING RESOURCE MODULE

module "RESOURCES" {
  source = "./modules/RESOURCES"
  providers = {
    aws = aws.Root
  }
}

