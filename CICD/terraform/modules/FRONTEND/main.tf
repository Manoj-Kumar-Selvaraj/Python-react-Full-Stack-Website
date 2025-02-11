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

resource "aws_sns_topic" "Factoryoutlet_fronntend_cicd_notifications" {
  name = "factory-outlet-frontend-cicd-notifications-sns"

}

resource "aws_sns_topic_subscription" "Factoryoutlet_fronntend_cicd_notifications" {
  topic_arn = aws_sns_topic.Factoryoutlet_fronntend_cicd_notifications.arn
  protocol = "email"
  endpoint = "ss.mano1998@gmail.com" 
}

resource "aws_ecr_repository" "custom_nodejs_image" {
  name                 = "nodejs-repo"  
  image_tag_mutability = "MUTABLE"   #This means that you can push a new image to ECR with the same tag name, replacing the old image.             
  tags = {
    OwnerGroup  = "FactoryOutlet-Frontend"
    Environment = "Production"
  }
}

resource "null_resource" "ecr_login" {
  provisioner "local-exec" {
    command = "aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${aws_ecr_repository.custom_nodejs_image.repository_url}"
  }
}

resource "null_resource" "docker_push" {
  depends_on = [aws_ecr_repository.custom_nodejs_image, null_resource.ecr_login]

  provisioner "local-exec" {
    command = <<EOT
      docker build -t ubuntu-docker-image /workspaces/Python-react-Full-Stack-Website/CICD/custom-ubuntu-docker
      docker tag ubuntu-docker-image:latest ${aws_ecr_repository.custom_nodejs_image.repository_url}:latest
      docker push ${aws_ecr_repository.custom_nodejs_image.repository_url}:latest
    EOT
  }
}

resource "aws_ecr_repository_policy" "codebuild_policy" {
  repository = aws_ecr_repository.custom_nodejs_image.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCodeBuildToPullImages",
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer"
      ]
    }
  ]
}
EOF
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
    image        = "${aws_ecr_repository.custom_nodejs_image.repository_url}:latest"
    type         = "LINUX_CONTAINER"
    privileged_mode = true
  }
  /*
  CodeBuild builds require a NAT Gateway to reach the internet, because they do not get assigned a public IP address like an EC2 instance does in a public subnet. You can think of it like CodeBuild builds are always in a private subnet in your VPC: https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Scenario2.html
    vpc_config {
    vpc_id           = aws_vpc.cicd_vpc.id
    subnets          = [aws_subnet.public_subnet.id]
    security_group_ids = [aws_security_group.public_access.id]
    }
  */
  source {
    type     = "GITHUB"
    location = "https://github.com/Manoj-Kumar-Selvaraj/Python-react-Full-Stack-Website#frontend"
    buildspec = <<BUILD_SPEC
version: 0.2

phases:
  install:
    commands:
      - echo Installing dependencies...
      - curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
      - apt-get install -y nodejs
      - node -v
      - npm -v
      - npm install

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
  name        = "factory_outlet_githum_secret_string"
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
    name = "Approval"
    action {
      name      = "ManualApproval"
      category  = "Approval"
      owner     = "AWS"
      provider  = "Manual"
      version   = "1"
      configuration = {
        NotificationArn = aws_sns_topic.Factoryoutlet_fronntend_cicd_notifications.arn
        CustomData      = "Please review the build and approve."
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

# Create an ACM SSL Certificate for HTTPS
resource "aws_acm_certificate" "ssl_cert" {
  domain_name       = "manoj-techworks.site"  # Change to your domain
  validation_method = "DNS"

    subject_alternative_names = [
    "www.manoj-techworks.site"
  ]

  lifecycle {
    create_before_destroy = true
  }
}

# CloudFront Distribution with S3 as Origin

resource "aws_cloudfront_distribution" "factoryoutlet-frontend-distribution" {
  origin {
    domain_name = "factoryoulet-front-end-host.s3.amazonaws.com"
    origin_id   = "factoryoutlet-origin-id"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"


  # Viewer (HTTPS) Settings
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.ssl_cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

    # Cache Behavior
  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "factoryoutlet-origin-id"
    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
  }

    restrictions {
    geo_restriction {
      restriction_type = "none"  # No restrictions, or use "whitelist"/"blacklist" with countries
    }
  }
  # Attach custom domain
  aliases = ["manoj-techworks.site", "www.manoj-techworks.site"]
}

output "cloudfront_url" {
  value = aws_cloudfront_distribution.factoryoutlet-frontend-distribution.domain_name
}