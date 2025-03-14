terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  alias   = "account2"
  region  = "us-east-1"  # Replace with your preferred AWS region
  profile = "account2"    # Replace with your AWS CLI profile name, if applicable
}