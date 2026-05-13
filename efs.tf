locals {
  efs_name                = "efs-${local.aws_regions_short[var.region]}-${var.environment}-${var.project_name}"
  efs_security_group_name = "efs-${local.aws_regions_short[var.region]}-${var.environment}-${var.project_name}-sg"
  efs_private_subnet_ids  = [for subnet_id in var.vpc_private_subnet_ids : subnet_id if trimspace(subnet_id) != ""]
  efs_mount_target_count  = var.enable_efs_csi ? (var.provision_vpc ? 3 : length(local.efs_private_subnet_ids)) : 0
}

resource "aws_security_group" "efs" {
  count = var.enable_efs_csi ? 1 : 0

  name        = local.efs_security_group_name
  description = "Security group for EFS NFS access from EKS worker nodes"
  vpc_id      = var.provision_vpc ? module.common_vpc[0].vpc_id : var.vpc_id
  tags        = merge(local.aws_default_tags, { Name = local.efs_security_group_name })
}

resource "aws_security_group_rule" "efs_nfs_ingress_from_eks_nodes" {
  count = var.enable_efs_csi ? 1 : 0

  type                     = "ingress"
  description              = "Allow NFS from EKS worker nodes"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.efs[0].id
  source_security_group_id = module.eks[0].node_security_group_id
}

resource "aws_security_group_rule" "efs_egress_all" {
  count = var.enable_efs_csi ? 1 : 0

  type              = "egress"
  description       = "Allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.efs[0].id
}

resource "aws_efs_file_system" "this" {
  count = var.enable_efs_csi ? 1 : 0

  creation_token                  = local.efs_name
  encrypted                       = var.efs_encrypted
  kms_key_id                      = var.efs_encrypted ? var.efs_kms_key_id : null
  performance_mode                = var.efs_performance_mode
  throughput_mode                 = var.efs_throughput_mode
  provisioned_throughput_in_mibps = var.efs_throughput_mode == "provisioned" ? var.efs_provisioned_throughput_in_mibps : null

  dynamic "lifecycle_policy" {
    for_each = var.efs_transition_to_ia != null ? [var.efs_transition_to_ia] : []
    content {
      transition_to_ia = lifecycle_policy.value
    }
  }

  dynamic "lifecycle_policy" {
    for_each = var.efs_transition_to_archive != null ? [var.efs_transition_to_archive] : []
    content {
      transition_to_archive = lifecycle_policy.value
    }
  }

  dynamic "lifecycle_policy" {
    for_each = var.efs_transition_to_primary_storage_class != null ? [var.efs_transition_to_primary_storage_class] : []
    content {
      transition_to_primary_storage_class = lifecycle_policy.value
    }
  }

  tags = merge(local.aws_default_tags, { Name = local.efs_name })
}

resource "aws_efs_mount_target" "this" {
  count = local.efs_mount_target_count

  file_system_id  = aws_efs_file_system.this[0].id
  subnet_id       = var.provision_vpc ? module.common_vpc[0].private_subnets[count.index] : local.efs_private_subnet_ids[count.index]
  security_groups = [aws_security_group.efs[0].id]
}

resource "aws_efs_backup_policy" "this" {
  count = var.enable_efs_csi ? 1 : 0

  file_system_id = aws_efs_file_system.this[0].id

  backup_policy {
    status = var.efs_backup_policy_enabled ? "ENABLED" : "DISABLED"
  }
}
