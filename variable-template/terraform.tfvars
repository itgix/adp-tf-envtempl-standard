environment    = "stg"
region         = "eu-west-1"
project_name   = "igxadp"
aws_account_id = "722377226063"

# Networking
provision_vpc       = true
vpc_cidr            = "10.51.0.0/16"
vpc_id              = ""
vpc_private_subnet_ids = ["", "", ""]
vpc_public_subnet_ids = ["", "", ""]

# EKS
provision_eks       = true
eks_cluster_version = "1.29"
eks_instance_types = [
  "m5a.large"
]
addons_versions = {
  "coredns"    = "v1.11.1-eksbuild.4"
  "kube_proxy" = "v1.29.0-eksbuild.1"
  "vpc_cni"    = "v1.16.0-eksbuild.1"
  "ebs_csi"    = "v1.27.0-eksbuild.1"
}
eks_ng_min_size     = 2
eks_ng_desired_size = 2
eks_ng_max_size     = 4

eks_aws_auth_roles = [
  {
    rolearn  = "eks-ec1-dev-itgix-role"
    username = "system:node:{{EC2PrivateDNSName}}"
    groups   = ["system:masters"]
  }
  #### Example for SSO ####
  # {
  #   rolearn  = "aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_4c46618bf79ed514"
  #   username = "eks-admin"
  #   groups   = ["system:masters"]
  # }
]
eks_aws_users_path = "/"
eks_aws_auth_users = [
  {
    username = "ytodorov"
    groups   = ["system:masters"]
  },
  {
    username = "bdimitrov"
    groups   = ["system:masters"]
  },
  {
    username = "aalexiev"
    groups   = ["system:masters"]
  },
  {
    username = "vdimitrov"
    groups   = ["system:masters"]
  },
  {
    username = "dmilanov"
    groups   = ["system:masters"]
  },
  {
    username = "nkazakov"
    groups   = ["system:masters"]
  },
  {
    username = "htonev"
    groups   = ["system:masters"]
  },
  {
    username = "mvukadinoff"
    groups   = ["system:masters"]
  }
]
eks_kms_key_users = [
  "arn:aws:iam::722377226063:user/users/mvukadinoff",
  "arn:aws:iam::722377226063:user/users/vdimitrov"
]
create_rds = true
rds_extra_credentials = {
  "username" = "demouser"
  "database" = "demodb"
}
rds_scaling_config = {
  min_capacity = 1
  max_capacity = 2
}
rds_config = {
    engine         = "aurora-postgresql"
    engine_version = "14.5"
    engine_mode    = "provisioned"
    cluster_family = "aurora-postgresql14"
    cluster_size   = 1
    db_port        = 5432
    db_name        = ""
}

# SQS
sqs_username = ""
sqs_iam_role_name = ""
provision_sqs = true
sqs_queues = {
  card-service_config = {
    sns_topic_name            = "config_topic"
    dlq_enable                = false
  }
  adyen-connector_config = {
    sns_topic_name            = "config_topic"
    dlq_enable                = false
  }
  checkout-connector_config = {
    sns_topic_name            = "config_topic"
    dlq_enable                = false
  }
  amex-connector_config = {
    sns_topic_name            = "config_topic"
    dlq_enable                = false
  }
  card-service_assets = {
    sns_topic_name            = "assets"
    dlq_enable                = false
  }
  card-service_payment-events = {
    sns_topic_name            = "payment-events"
    dlq_enable                = false
  }
  payment-service_payments = {
    sns_topic_name            = "payments"
    dlq_enable                = false
  }
  reporting-service_settlements = {
    sns_topic_name            = "settlements"
    dlq_enable                = false
  }
  reporting-service_payment-events = {
    sns_topic_name            = "payment-events"
    dlq_enable                = false
  }
  paypal-service_assets = {
    sns_topic_name            = "assets"
    dlq_enable                = false
  }
  reporting-service_assets = {
    sns_topic_name            = "assets"
    dlq_enable                = false
  }
  notification-service_payments = {
    sns_topic_name            = "payments"
    dlq_enable                = false
  }
  notification-service_assets = {
    sns_topic_name            = "assets"
    dlq_enable                = false
  }
  notification-service_payment-events = {
    sns_topic_name            = "payment-events"
    dlq_enable                = false
  }
  notification-service_settlements = {
    sns_topic_name            = "settlements"
    dlq_enable                = false
  }
}
sns_topics = {
 config_topic = {
    enable_fifo = false
  }
  assets = {
    enable_fifo = false
  }
  payments = {
    enable_fifo = false
  }
  payment-events = {
    enable_fifo = false
  }
  settlements = {
    enable_fifo = false
  }
}


### WAF vars

# WAF
application_waf_enabled       = false
cloudfront_waf_enabled        = false
waf_sampled_requests_enabled  = true
waf_webacl_cloudwatch_enabled = true
waf_logging_enabled           = true
waf_log_retention_days        = 365
# list of countries to be blocked by WAF
waf_country_codes_match = ["CU", "IR", "SY", "KP", "RU"] # list of countries to be blocked by WAF added by country code
aws_managed_waf_rule_groups = [
  // Baseline rule groups
  {
    name     = "AWSManagedRulesAdminProtectionRuleSet"
    priority = 1
    action   = "none"
  },
  {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 2
    action   = "none"
  },
  {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 3
    action   = "none"
  },
  // Use-case specific rule groups
  {
    name     = "AWSManagedRulesLinuxRuleSet"
    priority = 4
    action   = "none"
  },
  {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 5
    action   = "none"
  }
]

#ECR
provision_ecr = false
ecr_repository_type = "private"
ecr_repository_name = ""
ecr_repository_image_tag_mutability = "IMMUTABLE"
ecr_repository_encryption_type = "AES256"
ecr_repository_image_scan_on_push = true
ecr_repository_read_access_arns = []
ecr_repository_read_write_access_arns = []
ecr_manage_registry_scanning_configuration = true
ecr_registry_scan_type = "BASIC"
ecr_registry_scan_rules = []
ecr_create_lifecycle_policy = false

