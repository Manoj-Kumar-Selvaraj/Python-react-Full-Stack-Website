# CALLING THE SNSUSER MODULE

module "SNSUSER" {
  source = "./modules/SNSUSER"
  providers = {
    aws = aws.Root
  }
}
