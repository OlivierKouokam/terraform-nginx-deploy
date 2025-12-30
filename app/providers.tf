terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.10.0"
    }
  }

  required_version = "1.9.4"

  backend "s3" {
    bucket                   = "tf-state-mini-project"
    key                      = "mini-project.tfstate"
    region                   = "us-east-1"
    encrypt                  = true
    dynamodb_table           = "terraform-state-lock"
    shared_credentials_files = ["../.secrets/credentials"]
    profile                  = "app"
  }
}

provider "aws" {
  region                   = var.app_region
  shared_credentials_files = ["../.secrets/credentials"]
  profile                  = "app"
}