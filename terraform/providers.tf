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
  assume_role {
    role_arn     = "arn:aws:iam::039612868338:role/FactoryOutlet-Front-End-Root-Role"
    session_name = "Initial-setupsession"
  } 
  profile = "default"   
}
