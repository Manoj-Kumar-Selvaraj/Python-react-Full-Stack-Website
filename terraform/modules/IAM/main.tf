terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.81.0" # Ensure compatibility with your desired AWS provider version
    }
  }

  required_version = ">= 1.10.2" # Ensure compatibility with your Terraform version
}


resource "aws_iam_policy" "Secrets_Full_Access" {
  name = "UserSecrestManagerPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {Sid = "SecretsFullFullaccess",
      Effect = "Allow",
      Action = "secretsmanager:*",
      Resource = "*"
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
      }
    ]
  })
}

resource "aws_iam_policy" "UserCodeBuildCodePipelineS3Access" {
  name        = "UserCodeBuildCodePipelineS3Access"
  description = "Policy for users to manage CodeBuild and CodePipeline"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "CodePipelineMinimalAccess",
        Effect = "Allow",
        Action = [
          "codepipeline:List*",
          "codepipeline:Get*",
          "codepipeline:StartPipelineExecution",
          "codepipeline:CreatePipeline"
          ],
        Resource = "*"
      },
      {
        Sid    = "CodePipelineFullAccess",
        Effect = "Allow",
        Action = [
          "codepipeline:AcknowledgeJob",
          "codepipeline:AcknowledgeThirdPartyJob",
          "codepipeline:Create*",
          "codepipeline:Delete*",
          "codepipeline:DeregisterWebhookWithThirdParty",
          "codepipeline:Disable*",
          "codepipeline:Enable*",
          "codepipeline:OverrideStageCondition",
          "codepipeline:PollForJobs",
          "codepipeline:PollForThirdPartyJobs",
          "codepipeline:Put*",
          "codepipeline:RegisterWebhookWithThirdParty",
          "codepipeline:RetryStageExecution",
          "codepipeline:RollbackStage",
          "codepipeline:StopPipelineExecution",
          "codepipeline:TagResource",
          "codepipeline:UntagResource",
          "codepipeline:Update*",
          ],
        Resource = "*",
        Condition = {
          "StringEquals": {
            "dynamodb:ResourceTag/OwnerGroup": "FactoryOutlet"
          }
      }
      },
      {
        Sid       = "CodeBuildMinimalAccess",
        Effect    = "Allow",
        Action    = [ "codebuild:BatchGetBuildBatches",
                      "codebuild:BatchGetBuilds",
                      "codebuild:BatchGetProjects",
                      "codebuild:BatchGetReportGroups",
                      "codebuild:BatchGetReports",
                      "codebuild:DescribeCodeCoverages",
                      "codebuild:DescribeTestCases",
                      "codebuild:GetResourcePolicy",
                      "codebuild:ListBuilds",
                      "codebuild:ListProjects",
                      "codebuild:StartBuild",
                      "codebuild:Start*",
                      "codebuild:BatchGet*",
                      "codebuild:List*"
                    ]
        Resource  = "*"
      },
      {
        Sid       = "CodeBuildFullAccess",
        Effect    = "Allow",
        Action    = [ "codebuild:StopBuildBatch",
                      "codebuild:RetryBuild",
                      "codebuild:RetryBuildBatch",
                      "codebuild:CreateProject",
                      "codebuild:UpdateProject",
                      "codebuild:DeleteProject",
                      "codebuild:BatchGetBuildBatches",
                      "codebuild:BatchGetReports",
                      "codebuild:BatchPutCodeCoverages",
                      "codebuild:BatchPutTestCases",
                      "codebuild:PutResourcePolicy",
                      "codebuild:DeleteResourcePolicy",
                      "codebuild:DeleteOAuthToken",
                      "codebuild:PersistOAuthToken",
                      "codebuild:ImportSourceCredentials",
                      "codebuild:DeleteProject",
                      "codebuild:DeleteReport",
                      "codebuild:DeleteWebhook",
                      "codebuild:DescribeCodeCoverages",
                      "codebuild:GetReportGroupTrend",
                      "codebuild:ListReportsForReportGroup",
                      "codebuild:Delete*",
                      "codebuild:Update*",
                      "codebuild:Stop*",
                      "codebuild:BatchDeleteBuilds",
                      "codebuild:Create*",
                      "codebuild:BatchGetFleets",
                      "codebuild:InvalidateProjectCache"
                    ],
        Resource  = "*",
        Condition = {
          "StringEquals": {
            "dynamodb:ResourceTag/OwnerGroup": "FactoryOutlet"
          }
      }
    },
    {
      Sid = "S3FullAccess"
      Effect = "Allow",
      Action = ["S3:Get*",
                "S3:List*",
                "S3:Describe*",
                "S3:CreateBucket"],
      Resource = "*"
    },
        {
      Sid = "S3MinimalAccess"
      Effect = "Allow",
      Action = ["S3:Put*",
                "S3:Create*",
                "S3:Update*",
                "S3:Delete*",
                "S3:AbortMultipartUpload",
                "S3:AssociateAccessGrantsIdentityCenter",
                "S3:InitiateReplication",
                "S3:PauseReplication",
                "S3:SubmitMultiRegionAccessPointRoutes",
                "S3:ReplicateTags",
                "S3:TagResource",
                "S3:UntagResource",
                "S3:BypassGovernanceRetention",
                "S3:ObjectOwnerOverrideToBucketOwner",
                "S3:DissociateAccessGrantsIdentityCenter",
                "S3:ReplicateDelete",
                "S3:ReplicateObject",
                "S3:RestoreObject"
                ],
      Resource = "*"
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
        Sid       = "DynoDBMinimalAccess",
        Effect    = "Allow",
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
          "dynamodb:GetItem",
          "dynamodb:DescribeBackup",
          "dynamodb:DescribeContinuousBackups",
          "dynamodb:DescribeContributorInsights",
          "dynamodb:DescribeEndpoints",
          "dynamodb:DescribeExport",
          "dynamodb:DescribeGlobalTable",
          "dynamodb:DescribeGlobalTableSettings",
          "dynamodb:DescribeImport",
          "dynamodb:DescribeKinesisStreamingDestination",
          "dynamodb:DescribeLimits",
          "dynamodb:DescribeReservedCapacity",
          "dynamodb:DescribeReservedCapacityOfferings",
          "dynamodb:DescribeTableReplicaAutoScaling",
          "dynamodb:DescribeTimeToLive",
          "dynamodb:GetAbacStatus",
          "dynamodb:ListTagsOfResource",
          "dynamodb:PartiQLSelect",
          "dynamodb:ListBackups",
          "dynamodb:ListContributorInsights",
          "dynamodb:ListExports",
          "dynamodb:ListGlobalTables",
          "dynamodb:ListImports",
          "dynamodb:ListTables"
        ],
        Resource  = "*"
      },
      {
        Sid       = "DynoDBFullccAess",
        Effect    = "Allow",
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
          "dynamodb:DeleteTable",
          "dynamodb:GetResourcePolicy",
          "dynamodb:CreateBackup",
          "dynamodb:CreateGlobalTable",
          "dynamodb:CreateTable",
          "dynamodb:CreateTableReplica",
          "dynamodb:DeleteBackup",
          "dynamodb:DeleteTableReplica",
          "dynamodb:DisableKinesisStreamingDestination",
          "dynamodb:EnableKinesisStreamingDestination",
          "dynamodb:ExportTableToPointInTime",
          "dynamodb:ImportTable",
          "dynamodb:PartiQLDelete",
          "dynamodb:PartiQLInsert",
          "dynamodb:PartiQLUpdate",
          "dynamodb:PurchaseReservedCapacityOfferings",
          "dynamodb:RestoreTableFromAwsBackup",
          "dynamodb:RestoreTableFromBackup",
          "dynamodb:RestoreTableToPointInTime",
          "dynamodb:StartAwsBackupJob",
          "dynamodb:TagResource",
          "dynamodb:UntagResource",
          "dynamodb:UpdateContinuousBackups",
          "dynamodb:UpdateContributorInsights",
          "dynamodb:UpdateGlobalTable",
          "dynamodb:UpdateGlobalTableSettings",
          "dynamodb:UpdateGlobalTableVersion",
          "dynamodb:UpdateKinesisStreamingDestination",
          "dynamodb:UpdateTable",
          "dynamodb:UpdateTableReplicaAutoScaling",
          "dynamodb:UpdateTimeToLive",
          "dynamodb:DeleteResourcePolicy",
          "dynamodb:PutResourcePolicy",
          "dynamodb:UpdateAbacStatus"
        ],
        Resource  = "arn:aws:dynamodb:*:*:table/*",
        Condition = {
          "StringEquals": {
            "dynamodb:ResourceTag/OwnerGroup": "FactoryOutlet"
          }
      }
      }
    ]
  })
}

# EC2 Role and User Policy

resource "aws_iam_policy" "EC2_Read_Only" {
  name        = "EC2_Read_Only"
  description = "Read-only access to EC2 instances"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "EC2MinimalAccess"
        Effect   = "Allow",
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
          "ec2:Connect",
          "ec2:Get*",
          "ec2:Describe*",
          "ec2:List*"

        ],
        Resource = "*"
      },{
        Effect = "Allow",
        Action = "elasticloadbalancing:Describe*",
        Resource = "*",
      },
              {
            Effect = "Allow",
            Action = [
                "cloudwatch:ListMetrics",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:Describe*"
            ],
            Resource = "*"
        },
        {
            Effect = "Allow",
            Action = "autoscaling:Describe*",
            Resource = "*"
        }
    ]
  })
}

resource "aws_iam_policy" "EC2LaunchandConnect_Policy" {
  name        = "EC2LaunchandConnect_Policy"
  description = "EC2LaunchandConnect_Policy"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "EC2LaunchAndConnect",
        Effect   = "Allow",
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
          "ec2:CreateVpc",
          "ec2:Create*"                  
        ],
        Resource = "*"
      },
      {
        Sid = "EC2DeleteAccess"
        Effect   = "Allow",
        Action   = [
          "ec2:Delete*",
        ],
        Resource = "*",
                Condition = {
          "StringEquals": {
            "dynamodb:ResourceTag/OwnerGroup": "FactoryOutlet"
          }
      }
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
        Effect    = "Allow",
        Action    = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListAllMyBuckets"
        ],
        Resource  = [
          "arn:aws:s3:::aws_s3_bucket.FactoryOuletFrontEnd.id/*",
          "arn:aws:s3:::aws_s3_bucket.FactoryOuletFrontEnd.id"
        ]
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
        Effect = "Allow",
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds",
          "codebuild:BatchGetProjects",
          "codebuild:ListBuilds",
          "codebuild:ListProjects",
          "codebuild:ListReportGroups",
          "codebuild:ListCuratedEnvironmentImages",
          "codebuild:RetryBuild",
          "codebuild:StopBuild"
        ],
        Resource = "*"
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
        Effect    = "Allow",
        "Action": [
        "codepipeline:PollForJobs",
        "codepipeline:GetJobDetails",
        "codepipeline:PutJobSuccessResult",
        "codepipeline:PutJobFailureResult",
        "codepipeline:StartPipelineExecution",
        "codepipeline:GetPipelineState",
        "codepipeline:GetPipeline"
      ],
        Resource  = "*"
      },
      {
        Effect    = "Allow",
        Action    = "codepipeline:PutJobFailureResult",
        Resource  = "*"
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
        Effect    = "Allow",
        Action    = "iam:PassRole",
        Resource  = "*"
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
        Effect    = "Allow",
        Action    = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource  = "arn:aws:logs:*:*:log-group:/aws/codebuild/*"
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
        Effect    = "Allow",
        Action    = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource  = "arn:aws:logs:*:*:log-group:/aws/codepipeline/*"
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
        Effect    = "Allow",
        Principal = {
          Service = ["codepipeline.amazonaws.com"] 
        },
        Action   = "sts:AssumeRole"
      }
    ]
  })
}


# IAM Policy Attachment for CodePipeline Role
resource "aws_iam_policy_attachment" "code_pipeline_policy_attachment" {
  name       = "codepipeline-policy-attachment-${each.key}"
  for_each =  { 
                S3_policy = aws_iam_policy.S3_policy.arn,
                Codebuild_policy = aws_iam_policy.Codebuild_policy.arn,
                iam_pass_role_policy = aws_iam_policy.iam_pass_role_policy.arn,
                Codepipeline_cloudwatch_policy = aws_iam_policy.Codepipeline_cloudwatch_policy.arn,
                secrets_manager_policy = aws_iam_policy.secrets_manager_policy.arn,
                EC2_Read_Only = aws_iam_policy.EC2_Read_Only.arn
              }
  policy_arn = each.value
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
      }
    ]
  })
}



# IAM Policy Attachment for CodeBuild Role
resource "aws_iam_policy_attachment" "codebuild_policy_attachment" {
  name       = "codebuild-policy-attachment-${each.key}"
  for_each =    {
                S3_policy = aws_iam_policy.S3_policy.arn,
                Codepipeline_policy = aws_iam_policy.Codepipeline_policy.arn,
                iam_pass_role_policy = aws_iam_policy.iam_pass_role_policy.arn,
                CodeBuild_Cloudwatch_policy = aws_iam_policy.CodeBuild_Cloudwatch_policy.arn,
                secrets_manager_policy = aws_iam_policy.secrets_manager_policy.arn,
                EC2_Read_Only = aws_iam_policy.EC2_Read_Only.arn
                }
  policy_arn = each.value
  roles      = [aws_iam_role.codebuild_service_role.id]
}

resource "aws_iam_group_policy_attachment" "Attach_DynamoDB_Policy" {
  for_each =  {
                CodeBuildCodePipelineAccess = aws_iam_policy.UserCodeBuildCodePipelineS3Access.arn,
                DynamoDB_Access = aws_iam_policy.DynamoDB_Access.arn,
                EC2_Read_Only = aws_iam_policy.EC2_Read_Only.arn,
                Secrets_Full_Access = aws_iam_policy.Secrets_Full_Access.arn,
                EC2LaunchandConnect_Policy = aws_iam_policy.EC2LaunchandConnect_Policy.arn
  }
  policy_arn = each.value
  group = "FactoryOutlet"
}