resource "aws_vpc" "my_vpc" {
  cidr_block = "172.31.0.0/16"  
  provider          = aws.account2
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "MyVPC"
  }
}

resource "aws_subnet" "private_subnet_1" {
  provider          = aws.account2
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.31.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private Subnet 1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  provider          = aws.account2
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.31.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Private Subnet 2"
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  provider   = aws.account2
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  depends_on = [
    aws_vpc.my_vpc
  ]
  tags = {
    Name = "RDS Subnet Group"
  }
}


# Route Table for VPC 1 (EC2 module)
resource "aws_route_table" "vpc2_route_table" {
  provider = aws.account2
  vpc_id   = aws_vpc.my_vpc.id

  tags = {
    Name = "VPC1 Route Table"
  }
}

# Associate Route Table with Subnets
resource "aws_route_table_association" "subnet1_association" {
  provider          = aws.account2
  subnet_id         = aws_subnet.private_subnet_1.id
  route_table_id    = aws_route_table.vpc2_route_table.id
}

resource "aws_route_table_association" "subnet2_association" {
  provider          = aws.account2
  subnet_id         = aws_subnet.private_subnet_2.id
  route_table_id    = aws_route_table.vpc2_route_table.id
}


resource "aws_security_group" "rds_sg" {
  provider = aws.account2
    depends_on = [
    aws_vpc.my_vpc
  ]
  vpc_id   = aws_vpc.my_vpc.id

  ingress {
    description = "Allow MySQL Access"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Use restrictive ranges in production
  }
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow HTTP"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS Security Group"
  }
}