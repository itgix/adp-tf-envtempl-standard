terraform {
  # >= 1.11: write-only arguments (secret_string_wo) are used by the awssm module
  required_version = ">= 1.11, < 2.0"
  backend "s3" {}



  required_providers {
    # >= 6.50: secret_string_wo moves in place from secret_string
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.50, < 7.0"
    }
    # >= 3.7: ephemeral random_password
    random = {
      source  = "hashicorp/random"
      version = ">= 3.7, < 4.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# needed for WAF module
provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

provider "kubectl" {
  host                   = module.eks[0].eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks[0].eks_cluster_certificate_authority_data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks[0].eks_cluster_id]
  }
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
