terraform {
  required_version = "~> 1.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.20"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    region         = "eu-central-1"
    key            = "terraform.tfstate"
    bucket         = "itgix-dev-ec1-terraform-state-backend"
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = var.aws_default_tags
  }
}


