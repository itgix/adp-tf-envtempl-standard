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

 output "node_security_group_id" {
   description = "ID of the node shared security group"
   value       = module.eks.node_security_group_id
 }
