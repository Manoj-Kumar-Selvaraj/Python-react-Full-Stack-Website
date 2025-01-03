# CALLING S3LAM MODULE

module "S3LAM" {
  source = "./modules/S3LAM"
  providers = {
    aws = aws.Root
  }
}
