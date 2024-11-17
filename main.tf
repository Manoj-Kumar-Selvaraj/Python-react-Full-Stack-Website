module "EC2" {
  source = "./modules/EC2"

  providers = {
    aws = aws.default
  }
}

module "RDS" {
  source = "./modules/RDS"
  db_password     = var.db_password # Pass the variable to the module
  providers = {
    aws = aws.account2
  }
}