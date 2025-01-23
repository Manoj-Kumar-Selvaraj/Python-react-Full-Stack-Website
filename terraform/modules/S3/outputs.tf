output "main_lambda_snsfun_s3_lambda_bucket_name" {
   value = module.S3LAM.lambda_snsfun_s3_lambda_bucket_name
}

output "main_cloudtrail_cloudtrailusernotification_cloudtrail_bucket_name" {
    values=module.S3TRAIL.cloudtrail_cloudtrailusernotification_cloudtrail_bucket_name
}


