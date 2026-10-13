# AWS MSK Terraform Module

AWS MSK Terraform module. Based on the following modules:

- VPC module: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest
- CloudPosse MSK cluster module: https://registry.terraform.io/modules/cloudposse/msk-apache-kafka-cluster/aws/latest

## Usage

Use this module by adding a `module` configuration block, setting the `source` parameter to this repository, updating the `local_module_name` and `module_version`, then defining values for the environment variables in .tfvars files:

```hcl
module "local_module_name" {
    
  source  = "gitlab.com/bango/aws-msk-cluster/aws"
  version = "<latest_version>" # e.g "1.0.1"

  aws_region   = var.aws_region
  environment  = var.environment
  product_name = var.product_name

  msk_vpc_cidr        = var.msk_vpc_cidr
  allowed_cidr_blocks = var.allowed_cidr_blocks

  s3_log_bucket_name      = var.s3_log_bucket_name

  msk_cluster_kafka_version               = var.msk_cluster_kafka_version
  msk_cluster_broker_node_count           = var.msk_cluster_broker_node_count
  msk_cluster_broker_node_instance_type   = var.msk_cluster_broker_node_instance_type
  msk_cluster_broker_node_ebs_volume_size = var.msk_cluster_broker_node_ebs_volume_size

}

```

**NOTE**: The IAM authentication access is enabled by default. The authentication method can be changed in the deployment to the other authentication methods using the respective variables, however, to set **unauthenticated access** you need to take into account:
- The variable `client_broker` needs to be changed to "TLS_PLAINTEXT" or "PLAINTEXT" values to allow communication with the brokers.
- Plaintext traffic isn't possible with SASL/SCRAM or IAM access control methods, it is needed to set the variables of those methods to false.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.20 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.20 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kafka"></a> [kafka](#module\_kafka) | cloudposse/msk-apache-kafka-cluster/aws | ~> 2.4.0 |
| <a name="module_msk_vpc"></a> [msk\_vpc](#module\_msk\_vpc) | terraform-aws-modules/vpc/aws | >= 4.0.0, < 6.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.msk](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.firehose_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_kinesis_firehose_delivery_stream.msk](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) | resource |
| [aws_kms_key.msk](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_security_group.msk_cluster_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | List of CIDRs allowed by the security group | `list(any)` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to deploy to | `string` | n/a | yes |
| <a name="input_certificate_authority_arns"></a> [certificate\_authority\_arns](#input\_certificate\_authority\_arns) | List of ACM Certificate Authority Amazon Resource Names (ARNs) to be used for TLS client authentication | `list(string)` | `[]` | no |
| <a name="input_client_allow_unauthenticated"></a> [client\_allow\_unauthenticated](#input\_client\_allow\_unauthenticated) | Enables unauthenticated access. | `bool` | `false` | no |
| <a name="input_client_broker"></a> [client\_broker](#input\_client\_broker) | Encryption setting for data in transit between clients and brokers. Valid values: TLS, TLS\_PLAINTEXT, and PLAINTEXT. Plaintext traffic isn't possible with SASL/SCRAM or IAM access control methods. | `string` | `"TLS"` | no |
| <a name="input_client_sasl_iam_enabled"></a> [client\_sasl\_iam\_enabled](#input\_client\_sasl\_iam\_enabled) | Enables client authentication via IAM policies (cannot be set to true at the same time as client\_sasl\_*\_enabled). | `bool` | `true` | no |
| <a name="input_client_sasl_scram_enabled"></a> [client\_sasl\_scram\_enabled](#input\_client\_sasl\_scram\_enabled) | Enables SCRAM client authentication via AWS Secrets Manager (cannot be set to true at the same time as client\_tls\_auth\_enabled). | `bool` | `false` | no |
| <a name="input_client_sasl_scram_secret_association_arns"></a> [client\_sasl\_scram\_secret\_association\_arns](#input\_client\_sasl\_scram\_secret\_association\_arns) | List of AWS Secrets Manager secret ARNs for scram authentication (cannot be set to true at the same time as client\_tls\_auth\_enabled). | `list(string)` | `[]` | no |
| <a name="input_client_tls_auth_enabled"></a> [client\_tls\_auth\_enabled](#input\_client\_tls\_auth\_enabled) | Set true to enable the Client TLS Authentication | `bool` | `false` | no |
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#input\_cloudwatch\_log\_group\_retention\_in\_days) | Specifies the number of days you want to retain log events in the log group | `number` | `0` | no |
| <a name="input_cloudwatch_logs_enabled"></a> [cloudwatch\_logs\_enabled](#input\_cloudwatch\_logs\_enabled) | Indicates whether you want to enable or disable streaming broker logs to Cloudwatch Logs. | `bool` | `false` | no |
| <a name="input_enhanced_monitoring"></a> [enhanced\_monitoring](#input\_enhanced\_monitoring) | Specify the desired enhanced MSK CloudWatch monitoring level. Valid values: DEFAULT, PER\_BROKER, and PER\_TOPIC\_PER\_BROKER | `string` | `"DEFAULT"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment in which resources are deployed | `string` | n/a | yes |
| <a name="input_firehose_logs_enabled"></a> [firehose\_logs\_enabled](#input\_firehose\_logs\_enabled) | Indicates whether you want to enable or disable streaming broker logs to Kinesis Data Firehose | `bool` | `false` | no |
| <a name="input_jmx_exporter_enabled"></a> [jmx\_exporter\_enabled](#input\_jmx\_exporter\_enabled) | Indicates whether you want to enable or disable the JMX Exporter. | `bool` | `false` | no |
| <a name="input_msk_cluster_broker_node_ebs_volume_size"></a> [msk\_cluster\_broker\_node\_ebs\_volume\_size](#input\_msk\_cluster\_broker\_node\_ebs\_volume\_size) | The size in GiB of the EBS volume for the data drive on each broker node | `number` | n/a | yes |
| <a name="input_msk_cluster_broker_node_instance_type"></a> [msk\_cluster\_broker\_node\_instance\_type](#input\_msk\_cluster\_broker\_node\_instance\_type) | The instance type to use for the Kafka brokers | `string` | n/a | yes |
| <a name="input_msk_cluster_broker_per_zone"></a> [msk\_cluster\_broker\_per\_zone](#input\_msk\_cluster\_broker\_per\_zone) | Number of Kafka brokers per zone. | `number` | n/a | yes |
| <a name="input_msk_cluster_kafka_version"></a> [msk\_cluster\_kafka\_version](#input\_msk\_cluster\_kafka\_version) | The desired Kafka software version | `string` | n/a | yes |
| <a name="input_msk_create_vpc"></a> [msk\_create\_vpc](#input\_msk\_create\_vpc) | The default for creating a VPC where to provision MSK | `bool` | `true` | no |
| <a name="input_msk_subnet_ids"></a> [msk\_subnet\_ids](#input\_msk\_subnet\_ids) | IDs of subnets to be used by MSK cluster. This value will be ignored in case msk\_create\_vpc is set to true. | `list(string)` | `[]` | no |
| <a name="input_msk_vpc_cidr"></a> [msk\_vpc\_cidr](#input\_msk\_vpc\_cidr) | CIDR of VPC to be used by MSK cluster. This value will be ignored in case msk\_create\_vpc is set to false. | `string` | `""` | no |
| <a name="input_msk_vpc_id"></a> [msk\_vpc\_id](#input\_msk\_vpc\_id) | ID of VPC to be used by MSK cluster. This value will be ignored in case msk\_create\_vpc is set to true. | `string` | `""` | no |
| <a name="input_msk_vpc_subnet_newbits"></a> [msk\_vpc\_subnet\_newbits](#input\_msk\_vpc\_subnet\_newbits) | Number of additional bits with which to extend the prefix. This value will be ignored in case msk\_create\_vpc is set to false | `number` | `8` | no |
| <a name="input_node_exporter_enabled"></a> [node\_exporter\_enabled](#input\_node\_exporter\_enabled) | Indicates whether you want to enable or disable the Node Exporter. | `bool` | `false` | no |
| <a name="input_product_name"></a> [product\_name](#input\_product\_name) | Bango platform instance (same as provided tag in default\_tags) | `string` | n/a | yes |
| <a name="input_s3_log_bucket_name"></a> [s3\_log\_bucket\_name](#input\_s3\_log\_bucket\_name) | Name of the S3 bucket to deliver logs to. Needed if `s3_logs_enabled` or `firehose_logs_enabled` are set to `true` | `string` | `""` | no |
| <a name="input_s3_logs_enabled"></a> [s3\_logs\_enabled](#input\_s3\_logs\_enabled) | Indicates whether you want to enable or disable streaming broker logs to S3 | `bool` | `true` | no |
| <a name="input_s3_logs_prefix"></a> [s3\_logs\_prefix](#input\_s3\_logs\_prefix) | Prefix to append to the S3 folder name logs are delivered to | `string` | `""` | no |
| <a name="input_server_properties"></a> [server\_properties](#input\_server\_properties) | Contents of the server.properties file. Supported properties are documented in the [MSK Developer Guide](https://docs.aws.amazon.com/msk/latest/developerguide/msk-configuration-properties.html) | `map(string)` | `{}` | no |
| <a name="input_storage_autoscaling_max_capacity"></a> [storage\_autoscaling\_max\_capacity](#input\_storage\_autoscaling\_max\_capacity) | Maximum size the autoscaling policy can scale storage. Defaults to msk\_cluster\_broker\_node\_ebs\_volume\_size | `number` | `null` | no |
| <a name="input_storage_autoscaling_target_value"></a> [storage\_autoscaling\_target\_value](#input\_storage\_autoscaling\_target\_value) | Percentage of storage used to trigger autoscaled storage increase | `number` | `60` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bootstrap_brokers"></a> [bootstrap\_brokers](#output\_bootstrap\_brokers) | A comma separated list of one or more hostname:port pairs of kafka brokers suitable to boostrap connectivity to the kafka cluster |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | Amazon Resource Name (ARN) of the MSK cluster |
| <a name="output_intra_subnet_route_table_ids"></a> [intra\_subnet\_route\_table\_ids](#output\_intra\_subnet\_route\_table\_ids) | List of IDs of intra route tables |
| <a name="output_msk_create_vpc"></a> [msk\_create\_vpc](#output\_msk\_create\_vpc) | If the MSK VPC will be created |
| <a name="output_msk_vpc_id"></a> [msk\_vpc\_id](#output\_msk\_vpc\_id) | The ID of the MSK VPC |
| <a name="output_zookeeper_connect_string"></a> [zookeeper\_connect\_string](#output\_zookeeper\_connect\_string) | A comma separated list of one or more hostname:port pairs to use to connect to the Apache Zookeeper cluster |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
