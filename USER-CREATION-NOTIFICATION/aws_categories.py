# AWS category mapping for clusters
aws_categories = {
    "Compute": ["ec2", "lambda", "batch", "ecs", "eks", "fargate"],
    "Storage": ["s3", "ebs", "efs", "fsx", "glacier"],
    "Database": ["rds", "dynamodb", "aurora", "redshift", "neptune"],
    "Networking": ["vpc", "elb", "route53", "cloudfront", "directconnect"],
    "Security": ["iam", "kms", "waf", "guardduty", "shield", "cognito"],
    "Monitoring": ["cloudwatch", "xray", "logs", "eventbridge", "sns", "sqs", "cloudtrail"],
    "Analytics": ["athena", "glue", "kinesis", "quicksight", "emr"],
    "Machine Learning": ["sagemaker", "rekognition", "comprehend", "forecast"],
    "Developer": ["codebuild", "codecommit", "codedeploy", "codepipeline"],
    "IoT": ["iot", "greengrass", "freertos", "sitewise"],
    "Other": ["organizations", "servicecatalog"]
}