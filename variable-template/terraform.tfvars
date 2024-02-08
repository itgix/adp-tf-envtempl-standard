environment    = "dev"
aws_region     = "eu-west-1"
project_name   = "itgix"
aws_account_id = "722377226063"
aws_default_tags = {
  "platform:environment" = "Development"
  "platform:customer"    = "Itgix"
}

# Networking
vpc_cidr            = "10.50.0.0/16"
allowed_cidr_blocks = ["10.50.0.0/16"]

# EKS
provision_eks       = false
eks_cluster_name    = "test-eks"
eks_cluster_version = "1.26"

addons_versions = {
  coredns    = "v1.9.3-eksbuild.11"
  kube_proxy = "v1.26.11-eksbuild.4"
  vpc_cni    = "v1.16.0-eksbuild.1"
}
