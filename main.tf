terraform {
  required_version = "~> 1.1"
  backend "s3" {
    region = "eu-central-1"
    key    = "terraform.tfstate"
    bucket = "itgix-dev-ec1-terraform-state-backend"
  }


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
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = module.eks[0].eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks[0].eks_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks[0].eks_cluster_id]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks[0].eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks[0].eks_cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks[0].eks_cluster_id]
    }
  }
}

data "aws_caller_identity" "current" {}
