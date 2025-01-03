variable main_snsuser_sns_topic {
  type = string
  Description = "snsuser module sns topic object for using it in depends on"
}

variable main_snsuser_sns_topic_arn {
  type = string
  Description = "snsuser module sns topic arn for using it in resources"
}

variable iam_permissions_lambda_execution_role {
  type = string
  description = "lambda role object"
}

variable iam_permissions_lambda_execution_role_arn {
  type = string
  description = "lambda role object arn"
}

variable s3_s3lam_bucket_lambda_bucket {
  type = string
  description = "s3lam bucket object"
}

variable s3_s3lam_bucket_lambda_bucket_name {
  type = string
  description = "s3lam bucket name"
}

variable iam_resources_user_factory_outlet_frontend_developer1 {
  type = string
  description = "User Name"
}
