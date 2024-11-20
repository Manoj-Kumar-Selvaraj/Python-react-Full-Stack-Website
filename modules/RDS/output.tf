output "rds_vpc_id" {
  value = aws_vpc.my_vpc.id
  description = "VPC ID for the RDS module"
}

output "rds_route_table_id" {
  value       = aws_route_table.vpc2_route_table.id 
  description = "Route Table ID for the VPC"
}

output "rds_vpc_cidr" {
  value       = aws_vpc.my_vpc.cidr_block  # Replace with actual VPC resource name
  description = "CIDR block of the VPC"
}
