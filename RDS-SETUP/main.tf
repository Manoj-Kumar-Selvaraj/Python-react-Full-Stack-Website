resource "aws_db_instance" "my_rds_instance" {
  provider           = aws.account2
  allocated_storage  = 20
  db_name            = "mydb"
  engine             = "mysql"
  engine_version     = "8.0"
  instance_class     = "db.t3.micro"
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  username           = "admin"
  password           = var.db_password          # Terraform will automatically pick up the TF_VAR_db_password environment variable and use it as the value for the db_password variable
  skip_final_snapshot = true

  tags = {
    Name = "My RDS Instance"
  }
}