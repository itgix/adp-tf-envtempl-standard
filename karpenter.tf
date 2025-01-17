resource "aws_iam_service_linked_role" "spot" {
  count            = var.ec2_spot_service_role ? 1 : 0
  aws_service_name = "spot.amazonaws.com"
}

## Karpenter
module "karpenter" {
  count                     = var.enable_karpenter ? 1 : 0
  source                    = "terraform-aws-modules/eks/aws//modules/karpenter"
  version                   = "19.21.0"
  cluster_name              = module.eks[0].eks_cluster_id
  queue_name                = local.karpenter_queue_name
  queue_managed_sse_enabled = true
  iam_role_arn              = module.eks[0].node_iam_role_arn
  create_iam_role           = false

  enable_karpenter_instance_profile_creation = true
  irsa_oidc_provider_arn                     = module.eks[0].oidc_provider_arn
  irsa_namespace_service_accounts            = ["${local.karpenter_namespace}:karpenter"]
  create_irsa                                = false
  irsa_use_name_prefix                       = false
}

