locals {
  aws_regions_short = {
    "ap-east-1"      = "ae1"
    "ap-northeast-1" = "an1"
    "ap-northeast-2" = "an2"
    "ap-northeast-3" = "an3"
    "ap-south-1"     = "as0"
    "ap-southeast-1" = "as1"
    "ap-southeast-2" = "as2"
    "ca-central-1"   = "cc1"
    "eu-central-1"   = "ec1"
    "eu-north-1"     = "en1"
    "eu-south-1"     = "es1"
    "eu-west-1"      = "ew1"
    "eu-west-2"      = "ew2"
    "eu-west-3"      = "ew3"
    "af-south-1"     = "fs1"
    "me-south-1"     = "ms1"
    "sa-east-1"      = "se1"
    "us-east-1"      = "ue1"
    "us-east-2"      = "ue2"
    "us-west-1"      = "uw1"
    "us-west-2"      = "uw2"
  }

  aws_default_tags = {
    "platform:environment" = "${var.environment}"
    "platform:customer"    = "${var.project_name}"
    "Project"              = "${var.project_name}"
    "Environment"          = "${var.environment}"
    "CostCenter"           = "n/a"
    "Application"          = "adp"
    "ManagedBy"            = "Terraform"
    "aws-apn-id"           = "pc:5uhf95x0bz6d518p795cfi07s"
  }


  vpc_name = "vpc-${local.aws_regions_short[var.region]}-${var.environment}-${var.project_name}-common"

  vpc_s3_endpoint_name = "s3-gateway-vpc-${local.aws_regions_short[var.region]}-${var.environment}-${var.project_name}-common"

  eks_name = "eks-${local.aws_regions_short[var.region]}-${var.environment}-${var.project_name}"

  # compact function will remove null elements from list to not interfere with jsonencode afterwards
  secrets_kms_key_arns = compact([
    length(module.rds_maindb) > 0 ? module.rds_maindb[0].rds_credentials_kms_key_arn : null,
    length(module.elasticache) > 0 ? module.elasticache[0].redis_secret_kms_key_arn : null
  ])

  karpenter_queue_name           = "queue-${var.region}-${var.environment}-karpenter"
  karpenter_namespace            = "karpenter"
  karpenter_service_account_name = "karpenter"
  classic_karpenter_enabled      = var.enable_karpenter && !var.enable_eks_auto_mode

  redis_allowed_cidr_blocks = concat(var.redis_allowed_cidr_blocks, [var.vpc_cidr])

  msk_name                                = "msk-${local.aws_regions_short[var.region]}-${var.environment}-${var.project_name}"
  msk_topic_resource_arn_prefix           = replace(module.msk_cluster.cluster_arn, "/:cluster/", ":topic")
  msk_consumer_groups_resource_arn_prefix = replace(module.msk_cluster.cluster_arn, "/:cluster/", ":group")

  msk_scram_users_secrets_obj = [
    for index, username in var.msk_scram_users_data_platform : {
      secretname = "AmazonMSK_${local.aws_regions_short[var.region]}-${var.environment}-${var.project_name}-${username}"
      username   = username
      password   = random_password.msk_scram_users_data_platform_password[index].result
      addedTs    = timestamp()
    }
  ]

  all_secrets_arns = var.client_sasl_scram_enabled ? concat(
    values(module.msk_superuser_secret[0].secret_arns),
    try(values(module.msk_users_secrets[0].rotate_secret_arns), [])
    # try(values(module.msk_other_users_secrets[0].rotate_secret_arns), []),
    # try(values(module.msk_additional_data_platform_users_secrets[0].rotate_secret_arns), [])
  ) : []
}
