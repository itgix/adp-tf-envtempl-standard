#########################################################################
##                     General Configuration Variables                 ##
#########################################################################

variable "aws_account_id" {
  type        = string
  description = "AWS account to deploy resources"
}

variable "region" {
  type        = string
  description = "AWS region to deploy to"
}

variable "environment" {
  type        = string
  description = "Environment in which the infrastructure is going to be deployed"
}

variable "project_name" {
  type        = string
  description = "Name of the project / client / product to be used in naming convention"
}

#########################################################################
##                   Networking Variables                              ##
#########################################################################
variable "provision_vpc" {
  type    = bool
  default = true
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR of VPC to be used by Resale common resources"
  default     = ""
}

variable "vpc_id" {
  type        = string
  description = "External VPC ID"
  default     = ""
}

variable "vpc_private_subnet_ids" {
  description = "External VPC private subnet IDs"
  type        = list(string)
  default     = [""]
}

variable "vpc_public_subnet_ids" {
  description = "External VPC public subnet IDs"
  type        = list(string)
  default     = [""]
}

#########################################################################
##                   EKS Variables                              ##
#########################################################################


variable "provision_eks" {
  type    = bool
  default = true
}

variable "eks_cluster_version" {
  type        = string
  description = "Desired Kubernetes cluster version"
  default     = "1.29"
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDRs with access to the EKS cluster. Restricted to customer and ITGix"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_log_retention_in_days" {
  type        = number
  description = "Cluster log retention in days"
  default     = 14
}

variable "addons_versions" {
  type = object({
    kube_proxy = string
    vpc_cni    = string
    coredns    = string
    ebs_csi    = string
  })
}

variable "eks_aws_auth_roles" {
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "eks_aws_auth_users" {
  type = list(object({
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "eks_kms_key_users" {
  description = "A list of IAM ARNs for [key users](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-users)"
  type        = list(string)
  default     = []
}

################################################################################
# Node group defaults
################################################################################

variable "eks_ami_type" {
  description = "Default AMI type for the EKS worker nodes"
  type        = string
  default     = "AL2_x86_64"
}

variable "eks_disk_size" {
  description = "Disk size of the root volume attached to the EKS worker nodes"
  type        = number
  default     = 50
}

variable "eks_instance_types" {
  description = "EC2 instance types for the EKS worker nodes"
  type        = list(string)
  default     = ["m5a.4xlarge"]
}

variable "eks_volume_type" {
  description = "Type of the root EBS volume attached to the EKS worker nodes"
  type        = string
  default     = "gp3"
}

variable "eks_volume_iops" {
  description = "Number of IOPs on the root EBS volumes"
  type        = number
  default     = 3000
}

variable "eks_ng_min_size" {
  description = "Minimum number of the worker nodes in the node group"
  type        = number
  default     = 2
}

variable "eks_ng_max_size" {
  description = "Maximum number of the worker nodes in the node group"
  type        = number
  default     = 5
}

variable "eks_ng_desired_size" {
  description = "Desired number of the worker nodes in the node group"
  type        = number
  default     = 2
}

variable "eks_ng_capacity_type" {
  description = "capacity type for node group nodes"
  type        = string
  default     = "SPOT"
}

#########################################################################
##                   RDS Variables                                     ##
#########################################################################
variable "create_rds" {
  type        = bool
  description = "If a new RDS and Proxy needs to be created"
  default     = false
}
variable "rds_config" {
  description = "Configuration for RDS resources"
  type = object({
    engine         = string
    engine_version = string
    engine_mode    = string
    cluster_family = string
    cluster_size   = number
    db_port        = number
    db_name        = string
  })
  default = ({
    engine         = "aurora-postgresql"
    engine_version = "14.5"
    engine_mode    = "provisioned"
    cluster_family = "aurora-postgresql14"
    cluster_size   = 1
    db_port        = 5432
    db_name        = ""
  })
}
variable "rds_scaling_config" {
  description = "The minimum and maximum number of Aurora capacity units (ACUs) for a DB instance"
  type = object({
    min_capacity = number
    max_capacity = number
  })
  default = ({
    min_capacity = 0.5
    max_capacity = 2.0
    }
  )
}
variable "rds_default_username" {
  type        = string
  description = "DB username"
  default     = "postgres"
}
variable "rds_iam_auth_enabled" {
  type        = bool
  description = "Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled"
  default     = false
}
variable "rds_logs_exports" {
  type        = list(string)
  description = "List of log types to export to cloudwatch. Aurora MySQL: audit, error, general, slowquery. Aurora PostgreSQL: postgresql"
  default     = ["postgresql"]
}

variable "rds_extra_credentials" {
  description = "Database extra credentials"
  type = object({
    username = string
    password = optional(string)
    database = string
  })
  default = {
    username = "demouser"
    database = "demodb"
  }
}
#variable "bucket_to_export_name" {
#  type        = string
#  description = "Variable to set the name of the bucket in the policy to export data from the database to S3"
#  default     = ""
#}
#
#variable "enable_rds_s3_exports" {
#  type        = bool
#  description = "If a the s3 exports needs to be enabled"
#  default     = false
#}

#########################################################################
##                   SQS Variables                                     ##
#########################################################################

variable "sqs_username" {
  type = string
  default = ""
  description = "If not empty, created IAM User for usage with SQS for a more granular access"
}
variable "sqs_iam_role_name" {
  type = string
  default = ""
  description = "If not empty, created IAM Role for usage with SQS for a more granular access"
}
variable "sqs_queues" {
  type = map
}
variable "sns_topics" {
  type = map
}
variable "provision_sqs" {
  type = string
  default = false 
  description = "Enables creation of SQS/SNS resources"
}

#########################################################################
##                   WAF Variables                                     ##
#########################################################################
variable "application_waf_enabled" {
  type        = bool
  description = "Specifies whether WAF should be provisioned"
  default     = false
}
variable "cloudfront_waf_enabled" {
  type        = bool
  description = "Specifies whether cloudfront for the WAF should be provisioned"
  default     = false
}
variable "waf_webacl_cloudwatch_enabled" {}
variable "waf_sampled_requests_enabled" {}
variable "waf_logging_enabled" {}
variable "waf_country_codes_match" {}
variable "waf_log_retention_days" {}
variable "aws_managed_waf_rule_groups" {}


