resource "aws_s3_bucket" "FactoryOuletFrontEnd" {
    bucket = "factoryoulet-front-end-host"
    acl = "private"
}
 
resource "aws_dynamodb_table" "terraform_lock_table" {
  name         = "terraform-lock-table"
  hash_key     = "LockID"
  read_capacity  = 5
  write_capacity = 5
 
  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_s3_bucket" "FactoryOuletFrontEnd" {
    bucket = "factoryoulet-front-end-host"
    acl = "private" 
    website {
    index_document = "index.html"
    error_document = "404.html"   # Changed error page
  }
   tags = {
    Name        = "FactoryOulet"
    Environment = "Production"
  }
}
resource "aws_iam_policy" "FactoryOuletFrontEndPolicy" {
  name = "factoryoulet-front-end-host-policy"
  description = "Policy to allow public read access to S3 bucket"
  policy = jsoncode({
    version = "2012-10-17"
    statement = [
      {
        Effect   = "Allow"
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::factoryoulet-front-end-host/*"
      }
      ]
    }
  )
}

