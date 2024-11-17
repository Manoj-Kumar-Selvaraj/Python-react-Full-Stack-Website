variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for the subnet"
  default     = "us-east-1a"
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  default     = "Back_End_Vpc"
}

variable "subnet_name" {
  description = "Name tag for the public subnet"
  default     = "Backed_End_Server_Subnet"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  default     = "ami-02b64affdd5de5d46"  # AMI ID shared from my old ec2 and AMI shld be available in the region we are working on.
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  default     = "t2.micro"
}