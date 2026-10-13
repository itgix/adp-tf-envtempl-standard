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

  msk_name = "msk-${local.aws_regions_short[var.region]}-${var.environment}-${var.project_name}"

  msk_security_group_name = "security-group-${local.aws_regions_short[var.region]}-${var.environment}-${var.project_name}-msk-cluster"

  msk_vpc_id     = var.msk_create_vpc ? module.msk_vpc.vpc_id : var.msk_vpc_id
  msk_subnet_ids = var.msk_create_vpc ? module.msk_vpc.intra_subnets : var.msk_subnet_ids

  s3_logs_prefix                = var.s3_logs_enabled ? coalesce(var.s3_logs_prefix, "amazon_msk/") : ""
  firehose_role_name            = "role-${local.aws_regions_short[var.region]}-${var.environment}-${var.project_name}"
  firehose_delivery_stream_name = "firehose-${local.aws_regions_short[var.region]}-${var.environment}-${var.project_name}"
  firehose_delivery_stream      = var.firehose_logs_enabled ? aws_kinesis_firehose_delivery_stream.msk[0].name : ""
  cloudwatch_log_group_name     = "/aws/msk/broker_logs/msk-${local.aws_regions_short[var.region]}-${var.environment}-${var.project_name}"
  cloudwatch_logs_log_group     = var.cloudwatch_logs_enabled ? aws_cloudwatch_log_group.msk[0].name : null

  # client broker types
  plaintext     = "PLAINTEXT"
  tls_plaintext = "TLS_PLAINTEXT"
  tls           = "TLS"

  msk_security_group_ingress_rules = [
    {
      description = "Allows communication with brokers by using IAM access control"
      from_port   = 9098
      to_port     = 9098
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
      enabled     = var.client_sasl_iam_enabled && contains([local.tls_plaintext, local.tls], var.client_broker)
    },
    {
      description = "Allows communication with brokers by using SASL/SCRAM access"
      from_port   = 9096
      to_port     = 9096
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
      enabled     = var.client_sasl_scram_enabled && contains([local.tls_plaintext, local.tls], var.client_broker)
    },
    {
      description = "Allows communication with MSK brokers by using TLS encryption"
      from_port   = 9094
      to_port     = 9094
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
      enabled     = contains([local.tls_plaintext, local.tls], var.client_broker)
    },
    {
      description = "Allows communication with brokers in plaintext"
      from_port   = 9092
      to_port     = 9092
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
      enabled     = contains([local.plaintext, local.tls_plaintext], var.client_broker)
    },
    {
      description = "Allows communication with ZooKeeper by using TLS encryption"
      from_port   = 2182
      to_port     = 2182
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
      enabled     = true
    },
    {
      description = "Allows communication with Zookeeper by default"
      from_port   = 2181
      to_port     = 2181
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
      enabled     = true
    }
  ]
}
