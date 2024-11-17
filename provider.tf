terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Ensure compatibility with your desired AWS provider version
    }
  }

  required_version = ">= 1.3.0" # Ensure compatibility with your Terraform version
}

provider "aws" {
  alias   = "default"
  region  = "us-east-1"  # Replace with your preferred AWS region
  profile = "default"    # Replace with your AWS CLI profile name, if applicable
}

provider "aws" {
  alias   = "account2"
  region  = "us-east-1"  # Replace with your preferred AWS region
  profile = "account2"    # Replace with your AWS CLI profile name, if applicable
}