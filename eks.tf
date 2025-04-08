module "eks" {
  source = "git::git@github.com:itgix/tf-module-eks.git?ref=init-eks-auto-mode"
  count  = var.provision_eks ? 1 : 0

  providers = {
    aws = aws
  }

  aws_region  = var.region
  environment = var.environment

  eks_cluster_version = var.eks_cluster_version
  eks_cluster_name    = local.eks_name

  cluster_admins = var.eks_cluster_admins
  access_entries = var.eks_access_entries

  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  cluster_log_retention_in_days = var.cluster_log_retention_in_days

  vpc_id                   = var.provision_vpc ? module.common_vpc[0].vpc_id : var.vpc_id
  subnet_ids               = var.provision_vpc ? module.common_vpc[0].private_subnets : var.vpc_private_subnet_ids
  control_plane_subnet_ids = var.provision_vpc ? module.common_vpc[0].public_subnets : var.vpc_public_subnet_ids


  eks_tags = local.aws_default_tags

  kms_key_users        = var.eks_kms_key_users
  secrets_kms_key_arns = length(module.rds_maindb) > 0 ? local.secrets_kms_key_arns : "*"
}
