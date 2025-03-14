resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"
  tags = {
    "Application" = "FactoryOutlet"
    "Group"       = "Frontend"
  }
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_sns_permissions" {
  role = aws_iam_role.lambda_execution_role.name
  depends_on = [aws_iam_role.lambda_execution_role]
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["sns:Publish"],
        Resource = var.snsuser_sns_topic_arn,
        Condition = {
          StringEquals = {
            "aws:ResourceTag/Application" = "FactoryOutlet",
            "aws:ResourceTag/Group"      = "Frontend"
          }
        }
      },
     {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

# IAM Role for CloudWatch Logs integration
resource "aws_iam_role" "cloudwatch_logs_role" {
  name               = "cloudtrail-cloudwatch-logs-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Role Policy for CloudWatch Logs
resource "aws_iam_role_policy" "cloudwatch_logs_policy" {
  name = "cloudtrail-cloudwatch-logs-policy"
  role = aws_iam_role.cloudwatch_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["logs:PutLogEvents",
                    "logs:CreateLogStream",
                    "s3:PutObject"
                  ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}