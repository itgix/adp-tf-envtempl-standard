module "eks" {
  source = "git::git@gitlab.itgix.com:rnd/app-platform/iac-modules/elastic-kubernetes-service.git?ref=development"
  count  = var.provision_eks ? 1 : 0

  providers = {
    aws = aws
  }

  aws_region  = var.aws_region
  environment = var.environment

  eks_cluster_version = var.eks_cluster_version
  eks_cluster_name    = local.eks_name

  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs

  cluster_log_retention_in_days = var.cluster_log_retention_in_days
  addons_versions               = var.addons_versions

  vpc_id                   = module.common_vpc.vpc_id
  subnet_ids               = module.common_vpc.private_subnets
  control_plane_subnet_ids = module.common_vpc.public_subnets

  eks_ami_type                 = var.eks_ami_type
  eks_disk_size                = var.eks_disk_size
  eks_instance_types           = var.eks_instance_types
  eks_volume_type              = var.eks_volume_type
  eks_volume_iops              = var.eks_volume_iops

  eks_ng_min_size      = var.eks_ng_min_size
  eks_ng_max_size      = var.eks_ng_max_size
  eks_ng_desired_size  = var.eks_ng_desired_size
  eks_ng_capacity_type = var.eks_ng_capacity_type

  eks_aws_auth_users = var.eks_aws_auth_users

  eks_tags = var.aws_default_tags
}
