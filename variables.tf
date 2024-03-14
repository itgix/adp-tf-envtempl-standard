#########################################################################
##                     General Configuration Variables                 ##
#########################################################################

variable "aws_account_id" {
  type        = string
  description = "AWS account to deploy resources"
}

variable "aws_region" {
  type        = string
  description = "AWS region to deploy to"
}

variable "aws_default_tags" {
  type        = map(string)
  description = "Default tags to use in AWS resources"
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

variable "vpc_cidr" {
  type        = string
  description = "CIDR of VPC to be used by Resale common resources"
}

variable "allowed_cidr_blocks" {
  type        = list(any)
  description = "List of CIDRs allowed by the security group"
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

variable "eks_aws_auth_users" {
  description = "List of user maps to add to the aws-auth configmap"
  type        = list(any)
  default     = []
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
