# CALLING S3LAM MODULE

module "S3LAM" {
  source = "./modules/S3LAM"
}

# CALLING S3TRAIL MODULE

module "S3TRAIL" {
  source = "./modules/S3TRAIL"
  bucket_name = "usernotification-cloudtrail-bucket"
}

