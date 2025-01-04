resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "lambda-code-storage"
  tags = {
    "Application" = "FactoryOutlet"
    "Group"       = "Frontend"
  }
}

resource "aws_s3_object" "lambda_code" {
  depends_on = [aws_s3_bucket.lambda_bucket]
  bucket = aws_s3_bucket.lambda_bucket.bucket
  key    = "sns_lambda_function.zip"
  source = "sns_lambda_function.zip"
}
