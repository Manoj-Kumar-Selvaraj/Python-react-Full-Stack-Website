terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Use the latest supported version
    }
  }
}

provider "aws" {
  alias   = "FactoryOutletDBRootRole"
  region  = "us-east-1"
  assume_role {
    role_arn     = "arn:aws:iam::039612868338:role/FactoryOutletDBRootRole"
    session_name = "USERCREATION"
  } 
  profile = "FactoryOutletDBRoot"   
}
