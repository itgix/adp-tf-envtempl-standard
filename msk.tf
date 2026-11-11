#tfsec:ignore:aws-msk-enable-logging:2023-08-15
module "msk_cluster" {
  count = var.enable_msk ? 1 : 0

  source = "git::https://github.com/itgix/tf-module-msk.git?ref=v1.0.0"

  aws_region   = var.region
  environment  = var.environment
  product_name = var.project_name

  msk_vpc_cidr                              = var.provision_vpc ? module.common_vpc[0].vpc_cidr_block : var.vpc_cidr
  allowed_cidr_blocks                       = var.allowed_cidr_blocks
  msk_vpc_subnet_newbits                    = var.msk_vpc_subnet_newbits
  msk_create_vpc                            = false
  client_broker                             = var.client_broker
  client_sasl_scram_enabled                 = var.client_sasl_scram_enabled
  client_sasl_iam_enabled                   = var.client_sasl_iam_enabled
  client_allow_unauthenticated              = var.client_allow_unauthenticated
  client_sasl_scram_secret_association_arns = length(local.all_secrets_arns) > 0 ? local.all_secrets_arns : []
  msk_vpc_id                                = var.provision_vpc ? module.common_vpc[0].vpc_id : var.vpc_id
  msk_subnet_ids                            = var.provision_vpc ? module.common_vpc[0].database_subnets : var.vpc_private_subnet_ids
  s3_logs_enabled                           = var.s3_logs_enabled
  s3_log_bucket_name                        = var.s3_log_bucket_name
  cloudwatch_logs_enabled                   = var.cloudwatch_logs_enabled

  msk_cluster_kafka_version               = var.msk_cluster_kafka_version
  server_properties                       = var.msk_server_properties
  msk_cluster_broker_per_zone             = var.msk_cluster_broker_per_zone
  msk_cluster_broker_node_instance_type   = var.msk_cluster_broker_node_instance_type
  msk_cluster_broker_node_ebs_volume_size = var.msk_cluster_broker_node_ebs_volume_size
  storage_autoscaling_max_capacity        = var.msk_storage_autoscaling_max_capacity
  storage_autoscaling_target_value        = var.msk_storage_autoscaling_target_value
}

resource "random_password" "msk_scram_superuser_password" {
  count   = var.enable_msk && var.client_sasl_scram_enabled ? 1 : 0
  length  = 32
  special = true
}

resource "random_password" "msk_scram_users_password" {
  count = (
    var.enable_msk &&
    var.client_sasl_scram_enabled &&
    length(var.msk_scram_users) > 0
  ) ? length(var.msk_scram_users) : 0

  length  = 32
  special = true
}

resource "aws_kms_key" "msk_scram_secrets_kms_key" {
  count               = var.enable_msk && var.client_sasl_scram_enabled ? 1 : 0
  description         = "KMS key to be used to encrypt the ${local.msk_name} MSK cluster user secrets"
  enable_key_rotation = true
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Full Access for root account"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.aws_account_id}:root"
        }
        Action   = ["kms:*"]
        Resource = "*"
      },
    ]
  })
}

module "msk_superuser_secret" {
  count     = var.enable_msk && var.client_sasl_scram_enabled ? 1 : 0
  source    = "lgallard/secrets-manager/aws"
  version   = "0.6.2"
  unmanaged = true
  secrets = {
    "AmazonMSK_${local.aws_regions_short[var.region]}-${var.environment}-${var.project_name}-superuser" = {
      description = "MSK Cluster ${local.msk_name} Super user Credentials"
      kms_key_id  = aws_kms_key.msk_scram_secrets_kms_key[0].arn
      secret_key_value = {
        username = "kafka_superuser"
        password = random_password.msk_scram_superuser_password[0].result
      }
    }
  }
}
module "msk_users_secrets" {
  count = (
    var.enable_msk &&
    var.client_sasl_scram_enabled &&
    length(var.msk_scram_users) > 0
  ) ? 1 : 0
  source                   = "lgallard/secrets-manager/aws"
  version                  = "0.6.2"
  unmanaged                = true
  automatically_after_days = 180
  recovery_window_in_days  = 30
  # rotate_secrets = {
  #   for index, user in local.msk_scram_users_secrets_obj :
  #   local.msk_scram_users_secrets_obj[index].secretname => {
  #     description         = "MSK Cluster ${local.msk_name} user ${local.msk_scram_users_secrets_obj[index].username} Credentials"
  #     kms_key_id          = aws_kms_key.msk_scram_secrets_kms_key[0].arn
  #     rotation_lambda_arn = module.lambda_msk_secrets_rotation[0].lambda_function_arn
  #     secret_key_value = {
  #       username = local.msk_scram_users_secrets_obj[index].username
  #       password = local.msk_scram_users_secrets_obj[index].password
  #     }
  #   }
  # }
}

# moved {
#   from = random_password.msk_scram_users_password
#   to   = random_password.msk_scram_users_password
# }


#######################################
# MSK AUTHNZ
#######################################
data "aws_iam_policy_document" "msk_authnz_policy_documents" {
  for_each = local.msk_tenants

  statement {

    effect = "Allow"
    # This is to generate an uinque Policy Sid by hashing the composition of MSK engine arn and tenant name
    sid = format("MSKClusterPolicySid%s", substr(sha256(format("%s-%s", local.msk_cluster_arn, each.key)), 0, 5))

    actions = ["kafka-cluster:Connect",
      "kafka-cluster:DescribeCluster"
    ]

    resources = [local.msk_cluster_arn]

  }

  dynamic "statement" {
    for_each = local.msk_tenants[each.key].producer_topic_specs == null ? [] : [element(local.msk_tenants[each.key].producer_topic_specs, 0)]

    # Producer topic policies
    content {
      effect = "Allow"

      sid = format("MSKProducerTopicPolicySid%s", substr(sha256(format("%s-%s", local.msk_cluster_arn, each.key)), 0, 5))

      actions = [
        "kafka-cluster:WriteData",
        "kafka-cluster:ReadData",
        "kafka-cluster:*Topic*"
      ]

      resources = formatlist(format("%s/%%s", local.msk_topic_resource_arn_prefix), local.msk_tenants[each.key].producer_topic_specs)
    }
  }

  dynamic "statement" {
    for_each = local.msk_tenants[each.key].consumer_topic_specs == null ? [] : [element(local.msk_tenants[each.key].consumer_topic_specs, 0)]

    # Consumer topic policies
    content {
      effect = "Allow"

      sid = format("MSKConsumerTopicPolicySid%s", substr(sha256(format("%s-%s", local.msk_cluster_arn, each.key)), 0, 5))

      actions = [
        "kafka-cluster:ReadData",
        "kafka-cluster:DescribeTopic"
      ]

      resources = formatlist(format("%s/%%s", local.msk_topic_resource_arn_prefix), local.msk_tenants[each.key].consumer_topic_specs)
    }
  }

  dynamic "statement" {
    for_each = local.msk_tenants[each.key].consumer_group_specs == null ? [] : [element(local.msk_tenants[each.key].consumer_group_specs, 0)]

    # Consumer group policies
    content {
      effect = "Allow"

      sid = format("MSKConsumerGroupPolicySid%s", substr(sha256(format("%s-%s", local.msk_cluster_arn, each.key)), 0, 5))

      actions = [
        "kafka-cluster:AlterGroup",
        "kafka-cluster:DescribeGroup"
      ]

      resources = formatlist(format("%s/%%s", local.msk_consumer_groups_resource_arn_prefix), local.msk_tenants[each.key].consumer_group_specs)
    }
  }
}

# Register MSK IAM access policies
resource "aws_iam_policy" "msk_authnz_policy" {
  for_each = local.msk_tenants

  name        = format("msk-tenant-%s-policy", substr(sha256(format("%s-%s", local.msk_cluster_arn, each.key)), 0, 5))
  description = format("Policy for tenant role %s in MSK cluster %s", each.key, local.msk_cluster_arn)
  policy      = data.aws_iam_policy_document.msk_authnz_policy_documents[each.key].json
}

# Associate tenant IAM policy to relevant role
resource "aws_iam_role_policy_attachment" "msk_attach_to_tenant_role" {
  for_each = local.msk_tenants

  role       = each.key
  policy_arn = aws_iam_policy.msk_authnz_policy[each.key].arn
}
