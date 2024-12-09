terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = var.subnet_name
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Create a Security Group

resource "aws_security_group" "backed_server_sg" {
    name = "Backend_Server_SG"
    vpc_id = aws_vpc.main.id
    ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
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
      ingress {
    description = "Allow HTTP"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }
  egress {  # egress is outbound and -1 indicates all protocols
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# Generate an SSH key pair locally
resource "tls_private_key" "ssh_local" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create AWS Key Pair
resource "aws_key_pair" "backend_server_key" {
  key_name   = "backend_server_key"
  public_key = tls_private_key.ssh_local.public_key_openssh
}

# IAM Role in Account A to be assumed by Account B
resource "aws_iam_role" "cross_account_ec2_role_account1" {
  name     = "CrossAccountEC2Role_account1"

  # Trust policy to allow Account B to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::039612868338:root"  
        }
      }
    ]
  })
}

# Attach permissions to the IAM Role (e.g., AmazonEC2FullAccess)
resource "aws_iam_role_policy_attachment" "ec2_full_access_account1" {
  role      = aws_iam_role.cross_account_ec2_role_account1.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_instance_profile" "ec2_instance_profile_account1" {
  name     = "CrossAccountEC2InstanceProfile_account1"
  role     = aws_iam_role.cross_account_ec2_role_account1.name
}

# Resource: EC2 instance
resource "aws_instance" "ubuntu_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.backend_server_key.id
  associate_public_ip_address = true

  # Attach Security Group and Subnet
  vpc_security_group_ids = [aws_security_group.backed_server_sg.id]
  subnet_id              = aws_subnet.public.id

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile_account1.name

  tags = {
    Name = "Backed_End_Server"
  }
}