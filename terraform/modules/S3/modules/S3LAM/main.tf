resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "lambda-code-storage"
  tags = {
    "Application" = "FactoryOutlet"
    "Group"       = "Frontend"
  }
}

resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.lambda_bucket.bucket
  key    = var.lam_file
  source = var.lam_file
}
