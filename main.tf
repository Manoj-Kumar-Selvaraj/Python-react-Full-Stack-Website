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