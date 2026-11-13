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

  # msk_name                                = "msk-${local.aws_regions_short[var.region]}-${var.environment}-${var.project_name}"
  # msk_topic_resource_arn_prefix           = replace(module.msk_cluster.cluster_arn, "/:cluster/", ":topic")
  # msk_consumer_groups_resource_arn_prefix = replace(module.msk_cluster.cluster_arn, "/:cluster/", ":group")

  # all_secrets_arns = var.client_sasl_scram_enabled ? concat(
  #   values(module.msk_superuser_secret[0].secret_arns),
  #   try(values(module.msk_users_secrets[0].rotate_secret_arns), [])
  # ) : []

  # msk_scram_users_secrets_obj = [
  #   for index, username in var.msk_scram_users : {
  #     secretname = "AmazonMSK_${local.aws_regions_short[var.region]}-${var.environment}-${var.project_name}-${username}"
  #     username   = username
  #     password   = random_password.msk_scram_users_password[index].result
  #     addedTs    = timestamp()
  #   }
  # ]


  msk_name = "msk-${local.aws_regions_short[var.region]}-${var.environment}-${var.project_name}"

  # Safely retrieve the cluster ARN when MSK is enabled.
  msk_cluster_arn = try(module.msk_cluster[0].cluster_arn, null)

  msk_topic_resource_arn_prefix = var.enable_msk ? replace(
    local.msk_cluster_arn,
    "/:cluster/",
    ":topic"
  ) : null

  msk_consumer_groups_resource_arn_prefix = var.enable_msk ? replace(
    local.msk_cluster_arn,
    "/:cluster/",
    ":group"
  ) : null

  # MSK secrets
  # Names of every SCRAM secret associated with the MSK cluster. They must match the keys of the
  # `secrets` maps of module.msk_superuser_secret and module.msk_users_secrets in msk.tf; a mismatch
  # fails the lookup in aws_secretsmanager_secret_policy.msk_scram_secret. Names, not ARNs, so the
  # for_each keys are known at plan time.
  msk_scram_secret_names = (
    var.enable_msk && var.msk_client_sasl_scram_enabled
    ) ? concat(
    ["AmazonMSK_${local.aws_regions_short[var.region]}-${var.environment}-${var.project_name}-superuser"],
    sort([
      for user in var.msk_scram_users :
      "AmazonMSK_${local.aws_regions_short[var.region]}-${var.environment}-${var.project_name}-${user}"
    ])
  ) : []

  msk_scram_secret_arns_by_name = (
    var.enable_msk && var.msk_client_sasl_scram_enabled
    ) ? merge(
    module.msk_superuser_secret[0].secret_arns,
    try(module.msk_users_secrets[0].secret_arns, {})
  ) : {}

  # Derived from the secret policies, so the SCRAM secret association inside module.msk_cluster
  # only runs once kafka.amazonaws.com may read each secret and the secret versions exist.
  all_secrets_arns = [
    for name in local.msk_scram_secret_names :
    aws_secretsmanager_secret_policy.msk_scram_secret[name].secret_arn
  ]

  msk_scram_users_secrets_obj = (
    var.enable_msk && var.msk_client_sasl_scram_enabled
    ) ? [
    for index, username in var.msk_scram_users : {
      secretname = "AmazonMSK_${local.aws_regions_short[var.region]}-${var.environment}-${var.project_name}-${username}"
      username   = username
      password   = random_password.msk_scram_users_password[index].result
      addedTs    = timestamp()
    }
  ] : []

  # Only create tenant policies when MSK is enabled.
  msk_tenants = var.enable_msk ? var.msk_tenants : {}


}
