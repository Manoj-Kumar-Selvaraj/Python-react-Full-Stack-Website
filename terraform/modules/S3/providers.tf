terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.81.0" # Ensure compatibility with your desired AWS provider version
    }
  }
  required_version = ">= 1.9.8" # Ensure compatibility with your Terraform version 
}
provider "aws" {
  alias   = "Root"
  region  = "us-east-1"  
  profile = "default"   
}

