output "cloudtrail_cloudtrailusernotification_cloudtrail_bucket_name" {
    values=aws_s3_bucket.cloudtrail_bucket.bucket
}