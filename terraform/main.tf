resource "aws_s3_bucket" "FactoryOuletFrontEnd" {
    bucket = "factoryoulet-front-end-host"
    acl = "private"
}
 
resource "aws_dynamodb_table" "terraform_lock_table" {
  name         = "terraform-lock-table"
  hash_key     = "LockID"
  read_capacity  = 5
  write_capacity = 5
 
  attribute {
    name = "LockID"
    type = "S"
  }
}