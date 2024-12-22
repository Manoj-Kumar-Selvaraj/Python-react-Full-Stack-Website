terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Ensure compatibility with your desired AWS provider version
    }
  }

  required_version = ">= 1.3.0" # Ensure compatibility with your Terraform version
}


resource "aws_iam_policy" "Secrets_Full_Access" {
  name = "UserSecrestManagerPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {Sid = "Full access"
      Effect = "Allow",
      Action = "secretsmanager:*",
      Resource = "*"
      Principal = "arn:aws:iam::686255975511:group/S3FactoryOutlet"
      }
    ]
  })
}
resource "aws_iam_policy" "UserCloudWatchFullAccess" {
  name        = "UserCloudWatchFullAccess"
  description = "Policy to provide full access to CloudWatch for users"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "CloudWatchFullAccess",
        Effect = "Allow",
        Action = [
          "cloudwatch:*",
          "logs:*"
        ],
        Resource = "*"
        Principal = "arn:aws:iam::686255975511:group/S3FactoryOutlet"
      }
    ]
  })
}

resource "aws_iam_policy" "UserCodeBuildCodePipelineAccess" {
  name        = "UserCodeBuildCodePipelineAccess"
  description = "Policy for users to manage CodeBuild and CodePipeline"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "CodePipelineAccess",
        Effect = "Allow",
        Action = [
          "codepipeline:StartPipelineExecution",
          "codepipeline:GetPipelineState",
          "codepipeline:ListPipelines",
          "codepipeline:GetPipeline",
          "codepipeline:GetPipelineExecution"
        ],
        Resource = "*"
      },
      {
        Sid    = "CodeBuildAccess",
        Effect = "Allow",
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds",
          "codebuild:ListBuilds",
          "codebuild:StopBuild",
          "codebuild:ListProjects"
        ],
        Principal = "arn:aws:iam::686255975511:group/S3FactoryOutlet"
      }
    ]
  })
}

resource "aws_iam_policy" "DynamoDB_Access" {
  name        = "DynamoDBcreate"
  description = "This policy will give access to create view and use DynamoDB except destroying other users' tables"
  
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Sid       = "DynoDB Minimal Access"
        Effect    = "Allow"
        Action    = [
          "dynamodb:GetShardIterator",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:DescribeStream",
          "dynamodb:GetRecords",
          "dynamodb:ListStreams",
          "dynamodb:BatchGetItem",
          "dynamodb:ConditionCheckItem",
          "dynamodb:DescribeTable",
          "dynamodb:GetItem"
        ]
        Resource  = "*"
      },
      {
        Sid       = "DynoDB Full Access"
        Effect    = "Allow"
        Action    = [
          "dynamodb:GetShardIterator",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:DescribeStream",
          "dynamodb:GetRecords",
          "dynamodb:ListStreams",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:ConditionCheckItem",
          "dynamodb:PutItem",
          "dynamodb:DescribeTable",
          "dynamodb:DeleteItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteTable"
        ]
        Resource  = "arn:aws:dynamodb:*:*:table/*"
        Principal = "arn:aws:iam::686255975511:group/S3FactoryOutlet"
      }
    ]
  })
}

# EC2 Role and User Policy

resource "aws_iam_policy" "EC2ReadOnlyPolicy" {
  name        = "EC2ReadOnlyPolicy"
  description = "Read-only access to EC2 instances"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ec2-instance-connect:SendSSHPublicKey",    # This is important
          "ec2:DescribeInstances",
          "ec2:DescribeImages",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:DescribeKeyPairs",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeRegions",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:DescribeRouteTables",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeNetworkInterfaces",
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:Connect"
        ]
        Principal = "arn:aws:iam::686255975511:group/S3FactoryOutlet"
      },{
        Effect = "Allow"
        Action = "elasticloadbalancing:Describe*"
        Resource = "*"
      },
              {
            Effect = "Allow",
            Action = [
                "cloudwatch:ListMetrics",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:Describe*"
            ]
            Principal = "arn:aws:iam::686255975511:group/S3FactoryOutlet"
        },
        {
            Effect = "Allow",
            Action = "autoscaling:Describe*",
            Principal = "arn:aws:iam::686255975511:group/S3FactoryOutlet"
        }
    ]
  })
}

resource "aws_iam_policy" "EC2LaunchandConnectPolicy" {
  name        = "EC2LaunchandConnectPolicy"
  description = "EC2LaunchandConnectPolicy"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ec2:LaunchInstances",
          "ec2:CreateSecurityGroup",            
          "ec2:DescribeKeyPairs",
          "ec2:ModifyInstanceAttribute",
          "ec2:DeleteSecurityGroup", 
          "ec2:RevokeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RunInstances",
          "ec2:CreateTags",                  
        ]
        Resource = "*"
        Principal = "arn:aws:iam::686255975511:group/S3FactoryOutlet"
      }
    ]
  })
}



#S3 Role Policy

resource "aws_iam_policy" "S3_policy" {
  name        = "S3Policy"
  description = "Policy for CodePipeline to access specific S3 bucket"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListAllMyBuckets"
        ]
        Resource  = [
          "arn:aws:s3:::aws_s3_bucket.FactoryOuletFrontEnd.id/*",
          "arn:aws:s3:::aws_s3_bucket.FactoryOuletFrontEnd.id"
        ]
        Principal = "arn:aws:iam::686255975511:group/S3FactoryOutlet"
      }
    ]
  })
}

# CodeBuild Access

resource "aws_iam_policy" "Codebuild_policy" {
  name        = "CodeBuildPolicy"
  description = "Policy for CodePipeline to trigger builds in CodeBuild"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "codebuild:StartBuild"
        Resource  = "*"
        Principal = "arn:aws:iam::686255975511:group/S3FactoryOutlet"
      }
    ]
  })
}

#CodePipeline Access Policy

resource "aws_iam_policy" "Codepipeline_policy" {
  name        = "CodePipelinePolicy"
  description = "Policy for CodeBuild to interact with CodePipeline"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "codepipeline:PutJobSuccessResult"
        Resource  = "*"
        Principal = "arn:aws:iam::686255975511:group/S3FactoryOutlet"
      },
      {
        Effect    = "Allow"
        Action    = "codepipeline:PutJobFailureResult"
        Resource  = "*"
        Principal = "arn:aws:iam::686255975511:group/S3FactoryOutlet"
      }
    ]
  })
}

#Pass Role Policy

resource "aws_iam_policy" "iam_pass_role_policy" {
  name        = "PassRolePolicy"
  description = "Policy to allow CodePipeline to pass roles to CodeBuild"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "iam:PassRole"
        Resource  = "*"
        Principal = "arn:aws:iam::686255975511:group/S3FactoryOutlet"
      }
    ]
  })
}

resource "aws_iam_policy" "CodeBuild_Cloudwatch_policy" {
  name        = "CodeBuildCloudWatchPolicy"
  description = "Policy for CodeBuild to interact with CloudWatch Logs"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource  = "arn:aws:logs:*:*:log-group:/aws/codebuild/*"
        Principal = "arn:aws:iam::686255975511:group/S3FactoryOutlet"
      }
    ]
  })
}

resource "aws_iam_policy" "Codepipeline_cloudwatch_policy" {
  name        = "CodePipelineCloudWatchPolicy"
  description = "Policy for CodePipeline to interact with CloudWatch Logs"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource  = "arn:aws:logs:*:*:log-group:/aws/codepipeline/*"
        Principal = "arn:aws:iam::686255975511:group/S3FactoryOutlet"
      }
    ]
  })
}

#Policy for Secrets Manager


resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "SecretsManagerAccessPolicy"
  description = "Policy to allow access to specific secrets in Secrets Manager"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "SecretsManagerReadAccess",
        Effect    = "Allow",
        Action    = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets"
        ],
        Resource  =  "*"
        Principal = "arn:aws:iam::686255975511:group/S3FactoryOutlet"
      }
    ]
  })
}

# IAM Role for CodePipeline

resource "aws_iam_role" "code_pipeline_role" {
  name = "codepipeline-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = ["codepipeline.amazonaws.com"] 
        }
        Action   = "sts:AssumeRole"
        Principal = "arn:aws:iam::686255975511:group/S3FactoryOutlet"
      }
    ]
  })
}


# IAM Policy Attachment for CodePipeline Role
resource "aws_iam_policy_attachment" "code_pipeline_policy_attachment" {
  name       = "codepipeline-policy-attachment-${each.key}"
  for_each =  { 
                aws_iam_policy.S3_policy.arn,
                aws_iam_policy.Codebuild_policy.arn,
                aws_iam_policy.iam_pass_role_policy.arn,
                aws_iam_policy.Codepipeline_cloudwatch_policy.arn,
                aws_iam_policy.secrets_manager_policy.arn,
                aws_iam_policy.EC2ReadOnlyPolicy.arn
              }
  policy_arn = each.key
  roles      = [aws_iam_role.code_pipeline_role.id]
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
        Principal = "arn:aws:iam::686255975511:group/S3FactoryOutlet"
      }
    ]
  })
}



# IAM Policy Attachment for CodeBuild Role
resource "aws_iam_policy_attachment" "codebuild_policy_attachment" {
  name       = "codebuild-policy-attachment-${each.key}"
  for_each =    {
                aws_iam_policy.S3_policy.arn,
                aws_iam_policy.Codepipeline_policy.arn,
                aws_iam_policy.iam_pass_role_policy.arn,
                aws_iam_policy.CodeBuild_Cloudwatch_policy.arn,
                aws_iam_policy.secrets_manager_policy.arn,
                aws_iam_policy.EC2ReadOnlyPolicy.arn
                }
  policy_arn = each.key
  roles      = [aws_iam_role.codebuild_service_role.id]
}

resource "aws_iam_group_policy_attachment" "Attach_DynamoDB_Policy" {
  for_each =  {
                aws_iam_policy.UserCodeBuildCodePipelineAccess.arn,
                aws_iam_policy.DynamoDB_Access.arn,
                aws_iam_policy.iam_pass_role_policy.arn,
                aws_iam_policy.CodeBuild_Cloudwatch_policy.arn,
                aws_iam_policy.secrets_manager_policy.arn,
                aws_iam_policy.EC2ReadOnlyPolicy.arn,
                aws_iam_policy.Secrets_Full_Access.arn
                
  policy_arn = each.key
  group = "S3FactoryOutlet"
}