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

# CodeBuild Project for React App
resource "aws_codebuild_project" "react_app_build" {
  name = "react-app-build"
    tags = {
    OwnerGroup  = "FactoryOulet-Frontend"
    Environment = "Production"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/nodejs:latest"
    type         = "LINUX_CONTAINER"
    privileged_mode = true
  }
    vpc_config {
    vpc_id           = aws_vpc.cicd_vpc.id
    subnets          = [aws_subnet.public_subnet.id]
    security_group_ids = [aws_security_group.public_access.id]
    }

  source {
    type     = "GITHUB"
    location = "https://github.com/Manoj-Kumar-Selvaraj/Python-react-Full-Stack-Website"
    buildspec = <<BUILD_SPEC
version: 0.2

phases:
  install:
    commands:
      - echo Installing dependencies...
      - npm update
      - npm ci

  build:
    commands:
      - echo Building React app...
      - npm run build

artifacts:
  files:
    - '**/*'
  base-directory: build
BUILD_SPEC
  }

  artifacts {
    type     = "S3"
    location = aws_s3_bucket.FactoryOuletFrontEnd.bucket
    path     = "react-app-output"
  }

  service_role = var.code_build_role
}

# Secrets Manager to store GitHub OAuth Token
resource "aws_secretsmanager_secret" "github_oauth_token" {
  name        = "github_oauth_token_secret_string"
  description = "GitHub OAuth Token for AWS CodePipeline"
    tags = {
    OwnerGroup  = "FactoryOulet-Frontend"
    Environment = "Production"
  }
}
 
# Store OAuth Token in Secrets Manager
resource "aws_secretsmanager_secret_version" "github_oauth_token_version" {
  secret_id     = aws_secretsmanager_secret.github_oauth_token.id
  secret_string = var.git_pat
}

# CodePipeline for React App
resource "aws_codepipeline" "react_app_pipeline" {
  name     = "react-app-pipeline"
  role_arn = var.code_pipeline_role
  tags = {
    OwnerGroup  = "FactoryOulet-Frontend"
    Environment = "Production"
  }
  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.FactoryOuletFrontEnd.bucket
  }
 

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]
      configuration = {
        Owner      = "Manoj-Kumar-Selvaraj"
        Repo       = "Python-react-Full-Stack-Website"
        Branch     = "frontend"
        OAuthToken = aws_secretsmanager_secret_version.github_oauth_token_version.secret_string
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      version          = "1"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      configuration = {
        ProjectName = aws_codebuild_project.react_app_build.name
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name             = "Deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      input_artifacts  = ["build_output"]
      configuration = {
        BucketName = aws_s3_bucket.FactoryOuletFrontEnd.bucket
        Extract    = "true"
      }
    }
  }
}