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
  depends_on = [aws_iam_role.lambda_execution_role,var.snsuser_sns_topic]
  tags = {
    "Application" = "FactoryOutlet"
    "Group"       = "Frontend"
  }
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["sns:Publish"],
        Resource = "var.snsuser_sns_topic_arn"
        Condition = {
          "StringEquals": {
            "aws:ResourceTag/Application": "FactoryOulet",
            "aws:ResourceTag/Group"      : "Frontend" 
          }
      }
    ]
  })
}
