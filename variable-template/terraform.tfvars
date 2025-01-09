environment    = "min"
region         = "eu-west-1"
project_name   = "igxadp"
aws_account_id = "722377226063"
rds_iam_irsa   = true
provision_vpc  = true
vpc_cidr       = "10.56.0.0/16"
vpc_id         = "vpc-055db3bf67a2ee634"
vpc_private_subnet_ids = [
  "subnet-083c40359b035bf78",
  "subnet-0985ffa5c70209a49",
  "subnet-02a1b2dc0afc44049"
]
vpc_public_subnet_ids = [
  "subnet-02392ccef8efc30a9",
  "subnet-0f875da511ab96da4",
  "subnet-08f878f0703b72b50"
]
provision_eks       = true
eks_cluster_version = "1.30"
eks_instance_types = [
  "m5a.large"
]
addons_versions = {
  "coredns"    = "v1.11.4-eksbuild.1"
  "kube_proxy" = "v1.30.7-eksbuild.2"
  "vpc_cni"    = "v1.19.0-eksbuild.1"
  "ebs_csi"    = "v1.38.1-eksbuild.1"
}
eks_ng_min_size      = 2
eks_ng_desired_size  = 2
eks_ng_max_size      = 4
eks_ng_capacity_type = "SPOT"
eks_aws_auth_roles = [
  {
    "rolearn"  = "aws-reserved/sso.amazonaws.com/AWSReservedSSO_Non-Prod-AdministratorAccess_863469e97b9e999b"
    "username" = "eks-admin"
    "groups" = [
      "system:masters"
    ]
  }
]
eks_aws_users_path = "/users/"
eks_aws_auth_users = [
  {
    "username" = "ytodorov"
    "groups" = [
      "system:masters"
    ]
  },
  {
    "username" = "mvukadinoff"
    "groups" = [
      "system:masters"
    ]
  },
  {
    "username" = "htonev"
    "groups" = [
      "system:masters"
    ]
  },
  {
    "username" = "bdimitrov"
    "groups" = [
      "system:masters"
    ]
  },
  {
    "username" = "aalexiev"
    "groups" = [
      "system:masters"
    ]
  },
  {
    "username" = "tkazanova"
    "groups" = [
      "system:masters"
    ]
  },
  {
    "username" = "sracheva"
    "groups" = [
      "system:masters"
    ]
  }
]
eks_kms_key_users = [
  "arn:aws:iam::722377226063:user/users/mvukadinoff"
]
create_rds = true
rds_extra_credentials = {
  "username" = "demouser"
  "database" = "demodb"
}
rds_scaling_config = {
  "min_capacity" = 0.5
  "max_capacity" = 2
}
rds_config = {
  "engine"         = "aurora-postgresql"
  "engine_version" = "14.9"
  "engine_mode"    = "provisioned"
  "cluster_family" = "aurora-postgresql14"
  "cluster_size"   = 1
  "db_port"        = 5432
  "db_name"        = ""
}
rds_iam_auth_enabled = false
rds_logs_exports = [
  "postgresql"
]
rds_default_username = "postgres"
rds_allowed_cidr_blocks = [

]
sqs_username      = ""
sqs_iam_role_name = ""
provision_sqs     = false
sqs_queues = {
  "sample-service_queue" = {
    "sns_topic_name" = "sample_topic"
    "dlq_enable"     = false
  }
  "sample-secondservice_queue" = {
    "sns_topic_name" = "sample_topic"
    "dlq_enable"     = false
  }
}
sns_topics = {
  "sample_topic" = {
    "enable_fifo" = false
  }
  "sample_second_topic" = {
    "enable_fifo" = false
  }
}
application_waf_enabled       = false
cloudfront_waf_enabled        = false
waf_sampled_requests_enabled  = true
waf_webacl_cloudwatch_enabled = true
waf_logging_enabled           = true
waf_log_retention_days        = 365
waf_country_codes_match = [
  "CU",
  "IR",
  "SY",
  "KP",
  "RU"
]
aws_managed_waf_rule_groups = [
  {
    "name"     = "AWSManagedRulesAdminProtectionRuleSet"
    "priority" = 1
    "action"   = "none"
    "rules_override_to_count" = [

    ]
  },
  {
    "name"     = "AWSManagedRulesCommonRuleSet"
    "priority" = 2
    "action"   = "none"
    "rules_override_to_count" = [

    ]
  },
  {
    "name"     = "AWSManagedRulesKnownBadInputsRuleSet"
    "priority" = 3
    "action"   = "none"
    "rules_override_to_count" = [

    ]
  },
  {
    "name"     = "AWSManagedRulesLinuxRuleSet"
    "priority" = 4
    "action"   = "none"
    "rules_override_to_count" = [

    ]
  },
  {
    "name"     = "AWSManagedRulesSQLiRuleSet"
    "priority" = 5
    "action"   = "none"
    "rules_override_to_count" = [

    ]
  }
]
provision_ecr                       = false
ecr_repository_type                 = "private"
ecr_repository_name                 = ""
ecr_repository_image_tag_mutability = "IMMUTABLE"
ecr_repository_encryption_type      = "AES256"
ecr_repository_image_scan_on_push   = false
ecr_repository_read_access_arns = [

]
ecr_repository_read_write_access_arns = [

]
ecr_manage_registry_scanning_configuration = false
ecr_registry_scan_type                     = "BASIC"
ecr_registry_scan_rules = [

]
ecr_create_lifecycle_policy = false
create_elasticache_redis    = false
redis_cluster_size          = 1
redis_cluster_mode_enabled  = false
redis_instance_type         = "cache.t3.medium"
redis_engine_version        = "7.0"
redis_family                = "redis7"
redis_allowed_security_group_ids = [

]
redis_allowed_cidr_blocks = [
  "10.56.0.0/16"
]
redis_cloudwatch_logs_enabled    = true
redis_multi_az_enabled           = false
redis_automatic_failover_enabled = false
acm_certificate_enable           = true
dns_hosted_zone                  = "Z2INQZ6AA9H9SI"
dns_main_domain                  = "itgix.eu"
enable_karpenter                 = true
ec2_spot_service_role            = false
custom_secrets = [

]

ddb_create = false


ddb_table_configuration = [
  {
    #Default table
    table_name_suffix = "dynamodb-table"
    hash_key          = "Id"
    range_key         = "version"
    hash_key_type     = "S"
    range_key_type    = "N"
  }
]

ddb_global_create=false

ddb_global_table_configuration = [
  {
    #DefaultGlobalTable
    table_type        = "global"
    table_name_suffix = "dynamodb-global-table"
    replicas          = ["us-east-2", "eu-west-1"]
    dynamodb_attributes = [
      {
        name = "Id"
        type = "S"
      },
      {
        name = "version"
        type = "N"
      }
    ]
    hash_key                      = "Id"
    range_key                     = "version"
    hash_key_type                 = "S"
    range_key_type                = "N"
    enable_point_in_time_recovery = true
  }

]
