terraform {
  required_version = ">1"
  backend "s3" {
    bucket  = "jfrcorrea-event-processor"
    region  = "us-east-1"
    key     = "s3/terraform.tfstate"
    profile = "default"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.67.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}