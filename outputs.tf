output "eks_cluster_arn" {
  value = module.eks[0].eks_cluster_arn
}

output  "eks_cluster_name" {
  value = module.eks[0].eks_cluster_id
}

output "eks_cluster_endpoint" {
  value = module.eks[0].eks_cluster_endpoint
}

output "eks_cluster_certificate_authority_data" {
  value = module.eks[0].eks_cluster_certificate_authority_data
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
  description = "RDS Master Credentials Secret"
  value       = var.create_rds ? module.rds_maindb[0].rds_master_credentials_secret_arn : null
}

output "rds_cluster_identifier" {
  description = "The RDS Cluster Identifier"
  value       = var.create_rds ? module.rds_maindb[0].rds_cluster_identifier : null
}

output "rds_cluster_arn" {
  description = "The RDS Cluster ARN"
  value       = var.create_rds ? module.rds_maindb[0].rds_cluster_arn : null
}

output "rds_master_credentials_kms_key_arn" {
  description = "RDS Master Credentials kms key arn"
  value       = var.create_rds ? module.rds_maindb[0].rds_master_credentials_kms_key_arn : null
}
