resource "aws_kms_key" "msk" {
  description         = "MSK cluster encryption key"
  enable_key_rotation = true
}

#tfsec:ignore:aws-ec2-add-description-to-security-group
module "kafka" {
  source  = "cloudposse/msk-apache-kafka-cluster/aws"
  version = "~> 2.4.0"

  name                = local.msk_name
  kafka_version       = var.msk_cluster_kafka_version
  properties          = var.server_properties
  enhanced_monitoring = var.enhanced_monitoring

  ## broker node group
  broker_instance_type             = var.msk_cluster_broker_node_instance_type
  broker_volume_size               = var.msk_cluster_broker_node_ebs_volume_size
  broker_per_zone                  = var.msk_cluster_broker_per_zone
  storage_autoscaling_max_capacity = var.storage_autoscaling_max_capacity
  storage_autoscaling_target_value = var.storage_autoscaling_target_value

  ## Networking
  vpc_id                        = local.msk_vpc_id
  subnet_ids                    = local.msk_subnet_ids
  create_security_group         = false
  associated_security_group_ids = [aws_security_group.msk_cluster_sg.id]

  ## Encryption
  client_broker                  = var.client_broker
  encryption_at_rest_kms_key_arn = aws_kms_key.msk.arn

  ## Authentication
  client_tls_auth_enabled      = var.client_tls_auth_enabled
  certificate_authority_arns   = var.certificate_authority_arns
  client_allow_unauthenticated = var.client_allow_unauthenticated

  client_sasl_iam_enabled                   = var.client_sasl_iam_enabled
  client_sasl_scram_enabled                 = var.client_sasl_scram_enabled
  client_sasl_scram_secret_association_arns = var.client_sasl_scram_secret_association_arns

  ## Open monitoring
  jmx_exporter_enabled  = var.jmx_exporter_enabled
  node_exporter_enabled = var.node_exporter_enabled

  ##  Logging
  # Cloudwatch
  cloudwatch_logs_enabled   = var.cloudwatch_logs_enabled
  cloudwatch_logs_log_group = local.cloudwatch_logs_log_group
  # Firehose
  firehose_logs_enabled    = var.firehose_logs_enabled
  firehose_delivery_stream = local.firehose_delivery_stream
  # s3
  s3_logs_enabled = var.s3_logs_enabled
  s3_logs_bucket  = var.s3_log_bucket_name
  s3_logs_prefix  = local.s3_logs_prefix

}

data "aws_availability_zones" "available" {
  state = "available"
}

#tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs
module "msk_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 4.0.0, < 6.0"

  name                 = local.vpc_name
  cidr                 = var.msk_vpc_cidr
  azs                  = data.aws_availability_zones.available.names
  enable_dns_hostnames = true
  create_vpc           = var.msk_create_vpc
  ## Subnets
  intra_subnets = [
    cidrsubnet(var.msk_vpc_cidr, var.msk_vpc_subnet_newbits, 0),
    cidrsubnet(var.msk_vpc_cidr, var.msk_vpc_subnet_newbits, 1),
    cidrsubnet(var.msk_vpc_cidr, var.msk_vpc_subnet_newbits, 2)
  ]
  intra_subnet_assign_ipv6_address_on_creation = false
  map_public_ip_on_launch                      = false

}

resource "aws_security_group" "msk_cluster_sg" {
  name        = local.msk_security_group_name
  description = "Rules for MSK cluster"
  vpc_id      = local.msk_vpc_id
  dynamic "ingress" {
    for_each = [
      for rules in local.msk_security_group_ingress_rules : rules
      if rules.enabled
    ]
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}

#tfsec:ignore:aws-cloudwatch-log-group-customer-key
resource "aws_cloudwatch_log_group" "msk" {
  count             = var.cloudwatch_logs_enabled ? 1 : 0
  name              = local.cloudwatch_log_group_name
  retention_in_days = var.cloudwatch_log_group_retention_in_days
}

resource "aws_iam_role" "firehose_role" {
  count = var.firehose_logs_enabled ? 1 : 0
  name  = local.firehose_role_name

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          "Service" : "firehose.amazonaws.com"
        },
        Effect : "Allow",
        Sid : ""
      }
    ]
  })
}

resource "aws_kinesis_firehose_delivery_stream" "msk" {
  count       = var.firehose_logs_enabled ? 1 : 0
  name        = local.firehose_delivery_stream_name
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role[0].arn
    bucket_arn = "arn:aws:s3:::${var.s3_log_bucket_name}"
  }

  tags = {
    LogDeliveryEnabled = "false"
  }

  lifecycle {
    ignore_changes = [
      tags["LogDeliveryEnabled"],
    ]
  }
}
