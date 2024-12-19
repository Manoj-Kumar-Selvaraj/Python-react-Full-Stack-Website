# S3 Bucket for Website Hosting
resource "aws_s3_bucket" "FactoryOuletFrontEnd" {
  bucket = "factoryoulet-front-end-host"
  acl     = "private"

  website {
    index_document = "index.html"
    error_document = "404.html"   # Changed error page
  }

  tags = {
    Name        = "FactoryOulet"
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

# Terraform Backend Configuration for State Management
terraform {
  backend "s3" {
    bucket         = "factoryoulet-front-end-host"
    key            = "terraform/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
  }
}

# IAM Role for CodePipeline
resource "aws_iam_role" "codepipeline_service_role" {
  name = "codepipeline-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
        Action   = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy Attachment for CodePipeline Role
resource "aws_iam_policy_attachment" "codepipeline_policy_attachment" {
  name       = "codepipeline-policy-attachment"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess"
  roles      = [aws_iam_role.codepipeline_service_role.name]
}

# IAM Role for CodeBuild
resource "aws_iam_role" "codebuild_service_role" {
  name = "codebuild-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action   = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy Attachment for CodeBuild Role
resource "aws_iam_policy_attachment" "codebuild_policy_attachment" {
  name       = "codebuild-policy-attachment"
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
  roles      = [aws_iam_role.codebuild_service_role.name]
}

# CodeBuild Project for React App
resource "aws_codebuild_project" "react_app_build" {
  name = "react-app-build"

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/nodejs:latest"
    type         = "LINUX_CONTAINER"
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

  service_role = aws_iam_role.codebuild_service_role.arn
}

# Secrets Manager to store GitHub OAuth Token
resource "aws_secretsmanager_secret" "github_oauth_token" {
  name        = "github_oauth_token_secret_name"
  description = "GitHub OAuth Token for AWS CodePipeline"
}

# Store OAuth Token in Secrets Manager
resource "aws_secretsmanager_secret_version" "github_oauth_token_version" {
  secret_id     = aws_secretsmanager_secret.github_oauth_token.id
  secret_string = jsonencode({
    OAuthToken = var.git_pat
  })
}

# CodePipeline for React App
resource "aws_codepipeline" "react_app_pipeline" {
  name     = "react-app-pipeline"
  role_arn = aws_iam_role.codepipeline_service_role.arn

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
