module "EC2" {
  source = "./modules/EC2"
    providers = {
    aws = aws.default
  }
}
module "RDS" {
  source = "./modules/EC2"
    providers = {
    aws = aws.default
  }
}