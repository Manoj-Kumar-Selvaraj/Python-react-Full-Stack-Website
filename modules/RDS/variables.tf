variable "vpc_id_account2" {
  description = "VPC ID for account2"
  type        = string
}

variable "db_password" {
  description = "Password for the RDS instance"
  type        = string
  sensitive   = true
}
