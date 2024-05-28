output "eks_cluster_arn" {
  value = module.eks[0].eks_cluster_arn
}

output  "eks_cluster_name" {
  value = module.eks[0].eks_cluster_id
}

output "eks_cluster_endpoint" {
  value = module.eks[0].eks_cluster_endpoint
}

#output "eks_cluster_version" {
#  value = module.eks[0].eks_cluster_version
#}

output "eks_irsa_external_dns_arn" {
  value = module.eks[0].eks_irsa_external_dns_arn
}

## RDS
output "rds_cluster_endpoint" {
  description = "RDS Cluster endpoint"
  value       = var.create_rds ? module.rds_maindb[0].rds_cluster_endpoint : null
}

output "rds_master_credentials_secret_arn" {
  description = "RDS Master Credentials Secret ARN"
  value       = var.create_rds ? module.rds_maindb[0].rds_master_credentials_secret_arn : null
}

output "rds_master_credentials_secret_name" {
  description = "RDS Master Credentials Secret Name"
  value       = var.create_rds ? module.rds_maindb[0].rds_master_credentials_secret_name : null
}

output "rds_extra_credentials_secret_arn" {
  description = "RDS Extra Credentials Secret ARN"
  value       = var.create_rds ? module.rds_maindb[0].rds_extra_credentials_secret_arn : null
}

output "rds_extra_credentials_secret_name" {
  description = "RDS Extra Credentials Secret Name"
  value       = var.create_rds ? module.rds_maindb[0].rds_extra_credentials_secret_name : null
}

output "rds_cluster_identifier" {
  description = "The RDS Cluster Identifier"
  value       = var.create_rds ? module.rds_maindb[0].rds_cluster_identifier : null
}

output "rds_cluster_arn" {
  description = "The RDS Cluster ARN"
  value       = var.create_rds ? module.rds_maindb[0].rds_cluster_arn : null
}

output "rds_credentials_kms_key_arn" {
  description = "RDS Credentials kms key arn"
  value       = var.create_rds ? module.rds_maindb[0].rds_credentials_kms_key_arn : null
}

# WAF
output "waf_webacl_arn" {
  description = "RDS Credentials kms key arn"
  value       = var.application_waf_enabled ? module.wafv2_application.webacl_arn : null
}

# ECR

output "ecr_repository_name" {
  description = "Name of the repository"
  value       = module.ecr.repository_name
}

output "ecr_repository_arn" {
  description = "Full ARN of the repository"
  value       = module.ecr.repository_arn
}

output "ecr_repository_registry_id" {
  description = "The registry ID where the repository was created"
  value       = module.ecr.repository_registry_id
}

output "ecr_repository_url" {
  description = "The URL of the repository (in the form `aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName`)"
  value       = module.ecr.repository_url
}

# Elasticache Redis

output "redis_reader_endpoint_address" {
  description = "The address of the endpoint for the reader node in the replication group, if the cluster mode is disabled."
  value       = var.create_elasticache_redis ? module.elasticache[0].redis_reader_endpoint_address : null
}

output "redis_primary_endpoint_address" {
  description = "Redis primary or configuration endpoint, whichever is appropriate for the given cluster mode"
  value       = var.create_elasticache_redis ? module.elasticache[0].redis_primary_endpoint_address : null
}
output "irsa_rds_role_arn" {
  description = "ARN of the IAM Role for access to rds database"
  value       = var.create_elasticache_redis ?  module.rds_iam_auth[0].iam_role_arn : null
}

output "karpenter_queue_name" {
    description = "Interruption queue name for karpenter"
    value = "module.karpenter.queue_name"
}


output "karpenter_sa_role" {
    description = "IRSA role for karpenter SA"
    value = "module.karpenter.irsa_arn"
}

