resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = var.bucket_name
  tags = {
    "Application" = "FactoryOutlet"
    "Group"       = "Frontend"
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
  bucket = aws_s3_bucket.cloudtrail_bucket.bucket

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action   = "s3:GetBucketAcl",
        Resource = "${aws_s3_bucket.cloudtrail_bucket.arn}"  # Bucket ARN for GetBucketAcl
      },
      {
        Effect    = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "${aws_s3_bucket.cloudtrail_bucket.arn}/*",  # Object ARN for PutObject
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"  # Ensures bucket owner retains full control
          }
        }
      }
    ]
  })
}
