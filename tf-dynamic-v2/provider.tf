terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.0"
    }
  }
  backend "s3" {
    bucket         = "eazy-dynamic-bucket"
    key            = "dynamic.tfstate"
    dynamodb_table = "dynamic-tf-state-lock"
    encrypt        = true

    region                   = "us-east-1"
    shared_credentials_files = [".secrets/credentials"]
    profile                  = "dynamic"
  }
}

# Configure the AWS Provider
provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = [".secrets/credentials"]
  profile                  = var.aws_profile
}
