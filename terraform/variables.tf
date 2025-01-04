variable iam_sns_snsuser_sns_topic_arn {
  type = string
  default = "*"
  description = "snsuser module sns topic arn for using it in resources"
}

variable lambda_iam_permissions_lambda_execution_role {
  type = string
  description = "lambda role object"
}

variable lambda_iam_permissions_lambda_execution_role_arn {
  type = string
  description = "lambda role object arn"
}

variable lambda_s3_s3lam_bucket_lambda_bucket {
  type = string
  description = "s3lam bucket object"
}

variable lambda_s3_s3lam_bucket_lambda_bucket_name {
  type = string
  description = "s3lam bucket name"
}

variable sns_iam_resources_user_factory_outlet_frontend_developer1 {
  type = string
  description = "User Name"
}
