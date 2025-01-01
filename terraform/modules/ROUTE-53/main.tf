terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.81.0" # Ensure compatibility with your desired AWS provider version
    }
  }
  required_version = ">= 1.10.2" # Ensure compatibility with your Terraform version
}

resource "aws_vpc" "cicd_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    OwnerGroup  = "FactoryOulet-Frontend"
    Environment = "Production"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "cicd_vpc_igw" {
  vpc_id = aws_vpc.cicd_vpc.id
    tags = {
    OwnerGroup  = "FactoryOulet-Frontend"
    Environment = "Production"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.cicd_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    OwnerGroup  = "FactoryOulet-Frontend"
    Environment = "Production"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.cicd_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    OwnerGroup  = "FactoryOulet-Frontend"
    Environment = "Production"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.cicd_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cicd_vpc_igw.id
  }

  tags = {
    OwnerGroup  = "FactoryOulet-Frontend"
    Environment = "Production"
  }
}

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.id
}

# Security Group for Public Access
resource "aws_security_group" "public_access" {
  vpc_id = aws_vpc.cicd_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    OwnerGroup  = "FactoryOulet-Frontend"
    Environment = "Production"
  }
}

# DynamoDB Table for Locking Terraform State
resource "aws_dynamodb_table" "terraform_lock_table" {
  name         = "terraform-lock-table"
  hash_key     = "LockID"
  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    OwnerGroup  = "FactoryOulet-Frontend"
    Environment = "Production"
  }
}

# S3 Bucket for Website Hosting
resource "aws_s3_bucket" "FactoryOuletFrontEnd" {
  bucket = "factoryoulet-front-end-host"
  acl     = "private"

  website {
    index_document = "index.html"
    error_document = "404.html"   # Changed error page
  }
  versioning {
    enabled = true
  }

  tags = {
    OwnerGroup  = "FactoryOulet-Frontend"
    Environment = "Production"
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "FactoryOuletFrontEndPublicAccessBlock" {
  bucket = aws_s3_bucket.FactoryOuletFrontEnd.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# S3 Bucket Policy for Public Read Access
resource "aws_s3_bucket_policy" "FactoryOuletFrontEndBucketPolicy" {
  bucket = aws_s3_bucket.FactoryOuletFrontEnd.bucket

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "arn:aws:s3:::factoryoulet-front-end-host/*"
      }
    ]
  })
}

# Output Website URL
output "website_url" {
  value       = aws_s3_bucket.FactoryOuletFrontEnd.website_endpoint
  description = "React website URL"
}

