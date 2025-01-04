output "lambda_snsfun_s3_lambda_bucket_name" {
   value = aws_s3_bucket.lambda_bucket.bucket
}
output "lambda_snsfun_s3_lambda_bucket" {
   value = aws_s3_bucket.lambda_bucket
}
