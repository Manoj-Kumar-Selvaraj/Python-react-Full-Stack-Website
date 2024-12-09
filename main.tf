# EC2 Module
module "EC2" {
  source = "./modules/EC2"

  providers = {
    aws = aws.default
  }
}

# RDS Module
module "RDS" {
  source = "./modules/RDS"
  db_password = var.db_password  # Pass the variable to the module

  providers = {
    aws = aws.account2
  }
}

# VPC Peering Connection
resource "aws_vpc_peering_connection" "vpc_peering" {
  peer_owner_id = "039612868338" 
  depends_on    = [module.RDS.rds_vpc_id, module.EC2.ec2_vpc_id]
  peer_vpc_id   = module.RDS.rds_vpc_id         # Retrieve VPC ID from the RDS module output
  vpc_id        = module.EC2.ec2_vpc_id         # Retrieve VPC ID from the EC2 module output
  # auto_accept   = true                      # Automatically accept the peering connection, This should not be given true if there are two different accounts

  tags = {
    Name = "VPC-Peering-Connection"
  }
}


# Add routes for VPCs
resource "aws_route" "vpc1_to_vpc2" {
  route_table_id         = module.EC2.ec2_route_table_id  # Output from EC2 module
  destination_cidr_block = module.RDS.rds_vpc_cidr        # Output from RDS module
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}

resource "aws_route" "vpc2_to_vpc1" {
  provider               = aws.account2
  route_table_id         = module.RDS.rds_route_table_id  # Output from RDS module
  destination_cidr_block = module.EC2.ec2_vpc_cidr      # Output from EC2 module
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}

# IAM Role in Account B to assume the role from Account A
resource "aws_iam_role" "assume_cross_account_role" {
  provider = aws.account2
  name     = "AssumeCrossAccountEC2Role"

  # Trust policy allowing Account B to assume the role in Account A
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::202533516001:role/CrossAccountEC2Role_account1"  
        }
      }
    ]
  })
}

resource "aws_vpn_gateway" "onpremis_vpn_gateway" {
  vpc_id = module.EC2.ec2_vpc_id
}

resource "aws_customer_gateway" "My_cgw" {
  bgp_asn    = 65000
  ip_address = "49.207.63.76"
  type       = "ipsec.1"
}

resource "aws_vpn_connection" "My_vpn_connection" {
  customer_gateway_id = aws_customer_gateway.My_cgw.id
  vpn_gateway_id      = aws_vpn_gateway.onpremis_vpn_gateway.id
  type                = "ipsec.1"
  static_routes_only = true
}

resource "aws_vpn_connection_route" "strongswan_vpn_route" {
  vpn_connection_id = aws_vpn_connection.My_vpn_connection.id
  destination_cidr_block = "192.168.0.0/24" # Vpn Private pool
}

# Output VPN Details
output "vpn_connection_id" {
  value = aws_vpn_connection.My_vpn_connection.id
}
