output "code_pipeline_role" {
    description = "This is the code pipeline role output"
    value       = aws_iam_role.code_pipeline_role.arn
}

output "code_build_role" {
    description = "This is the code pipeline role output"
    value       = aws_iam_role.codebuild_service_role.arn
}