
output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.main.id
}


output "ec2_vpc_id" {
  value = aws_vpc.main.id
  description = "VPC ID for the EC2 module"
}


output "ec2_route_table_id" {
  value       = aws_route_table.public.id 
  description = "Route Table ID for the VPC"
}

output "ec2_vpc_cidr" {
  value       = aws_vpc.main.cidr_block  # Replace with actual VPC resource name
  description = "CIDR block of the VPC"
}
