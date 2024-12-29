variable git_pat {
  type        = string
  description = "Git PAT variable"
}

variable code_pipeline_role {
  type        = string
  default     = ""
  description = "code_pipeline_role_variable"
}

variable code_build_role {
  type        = string
  default     = ""
  description = "description"
}

variable Attach_UserEcrPolicy {
  type = string
}