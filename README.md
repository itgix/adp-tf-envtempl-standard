# Terraform Infrastructure Deployment

This is the standard template for the cloud infrastructure of **ITGix ADP - Application Development Container Platform**.  
It's meant to be used with the **idp-installer** bootstrapping script.

Variables can be passed via the main YAML configuration file of **idp-installer**, and they will override the provided defaults in the `variable-template` directory.

---

## VPC subnet layout

The VPC subnets are configurable. Each tier is described either by an explicit list of CIDRs, or - the default - by a subnet size (`newbits`, added to the VPC prefix length) and the `offsets` of the subnets inside `vpc_cidr`, counted in blocks of the resulting size exactly like the `cidrsubnet()` function.

With a `/16` `vpc_cidr` the defaults produce:

| Tier | Variable | Subnets | Usable IPs per AZ |
|------|----------|---------|-------------------|
| private | `vpc_private_subnets` | `10.x.0.0/21`, `10.x.8.0/21`, `10.x.16.0/21` | 2043 |
| database | `vpc_database_subnets` | `10.x.24.0/24`, `10.x.25.0/24`, `10.x.26.0/24` | 251 |
| public | `vpc_public_subnets` | `10.x.28.0/23`, `10.x.30.0/23`, `10.x.32.0/23` | 507 |

The three tiers occupy `[0, 3/32)`, `[3/32, 27/256)` and `[7/64, 17/128)` of the VPC range respectively, so the defaults cannot overlap at any `vpc_cidr` size - the private tier ends exactly where the database tier begins. A `check` assertion detects overlaps at plan time for custom layouts.

Environments created before these variables existed use `/26` private and public subnets (~60 usable IPs), which is not enough for EKS with the VPC CNI, where every pod consumes an address. The database ranges are unchanged.

### Keeping an existing environment as it is

`terraform` reads the subnets of an already provisioned VPC back from AWS (`aws_vpcs`/`aws_subnets` on the VPC `Name` tag) and reuses those exact ranges, so upgrading this template produces **no subnet changes** for a running environment. A `check` warning on every plan reports when the deployed layout differs from the configured one.

### Applying the new layout to an existing environment

Set `force_subnet_resize = true` to re-address the private and public subnets. This replaces the subnets and therefore every resource pinned to them:

* **replaced**: private/public subnets, route table associations, NAT gateways, EKS managed node groups (all nodes are rolled), EFS mount targets
* **kept**: the VPC itself, the EKS cluster and its add-ons/IRSA roles, the EFS file system, the RDS cluster, ElastiCache/Valkey

Before applying, delete the Kubernetes-managed load balancers (`Service type: LoadBalancer` and Ingress resources) - their ENIs are not managed by Terraform and will block the deletion of the old subnets. Expect workload downtime while the node groups are recreated.

Once the resize is applied the flag becomes a no-op (the deployed layout then matches the configured one), so it can be left in place.

The database tier has a separate flag, `force_database_subnet_resize`, because replacing the database subnets replaces the DB subnet group and with it the RDS cluster and the ElastiCache/Valkey replication groups. Leave it at `false` unless you have a restore plan.


## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.49 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.49 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | git::git@github.com:itgix/tf-module-acm.git | v1.0.2 |
| <a name="module_common_vpc"></a> [common\_vpc](#module\_common\_vpc) | terraform-aws-modules/vpc/aws | 6.7.2 |
| <a name="module_custom_secrets_password_module"></a> [custom\_secrets\_password\_module](#module\_custom\_secrets\_password\_module) | git@github.com:itgix/tf-module-awssm-passgen.git | v1.0.0 |
| <a name="module_dynamodb"></a> [dynamodb](#module\_dynamodb) | git@github.com:itgix/tf-module-dynamodb.git | n/a |
| <a name="module_ecr"></a> [ecr](#module\_ecr) | git::git@github.com:itgix/tf-module-ecr.git | v1.0.0 |
| <a name="module_eks"></a> [eks](#module\_eks) | git::https://github.com/itgix/tf-module-eks.git | v1.3.4 |
| <a name="module_elasticache"></a> [elasticache](#module\_elasticache) | git::git@github.com:itgix/tf-module-redis.git | v1.0.0 |
| <a name="module_global_dynamodb"></a> [global\_dynamodb](#module\_global\_dynamodb) | git@github.com:itgix/tf-module-dynamodb.git | n/a |
| <a name="module_irsa_fluentbit_cloudwatch"></a> [irsa\_fluentbit\_cloudwatch](#module\_irsa\_fluentbit\_cloudwatch) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.34.0 |
| <a name="module_irsa_itgix_adp_agent"></a> [irsa\_itgix\_adp\_agent](#module\_irsa\_itgix\_adp\_agent) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.34.0 |
| <a name="module_irsa_karpenter"></a> [irsa\_karpenter](#module\_irsa\_karpenter) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.34.0 |
| <a name="module_karpenter"></a> [karpenter](#module\_karpenter) | terraform-aws-modules/eks/aws//modules/karpenter | 19.21.0 |
| <a name="module_rds_iam_auth"></a> [rds\_iam\_auth](#module\_rds\_iam\_auth) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | 5.34.0 |
| <a name="module_rds_maindb"></a> [rds\_maindb](#module\_rds\_maindb) | git::git@github.com:itgix/tf-module-rds.git | v1.0.7 |
| <a name="module_sqs_dev"></a> [sqs\_dev](#module\_sqs\_dev) | git::git@github.com:itgix/tf-module-sqs-sns.git | v1.0.0 |
| <a name="module_wafv2_application"></a> [wafv2\_application](#module\_wafv2\_application) | git::git@github.com:itgix/tf-module-wafv2.git | v1 |
| <a name="module_wafv2_cloudfront"></a> [wafv2\_cloudfront](#module\_wafv2\_cloudfront) | git::git@github.com:itgix/tf-module-wafv2.git | v1 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.irsa_itgix_adp_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.irsa_karpenter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.rds_iam_auth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_service_linked_role.spot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_service_linked_role) | resource |
| [aws_subnet.common_database](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.common_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.common_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnets.common](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc_endpoint.s3_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_vpcs.common](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpcs) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_certificate_enable"></a> [acm\_certificate\_enable](#input\_acm\_certificate\_enable) | Generate a validated acm cert | `bool` | `false` | no |
| <a name="input_addons_versions"></a> [addons\_versions](#input\_addons\_versions) | Configuration of EKS add-ons; normal-mode and EFS requirements are validated by the EKS module | <pre>object({<br>    kube_proxy                  = optional(string)<br>    vpc_cni                     = optional(string)<br>    coredns                     = optional(string)<br>    ebs_csi                     = optional(string)<br>    efs_csi                     = optional(string)<br>    resolve_conflicts_on_create = optional(string, "OVERWRITE")<br>  })</pre> | <pre>{<br>  "coredns": "v1.13.2-eksbuild.21",<br>  "ebs_csi": "v1.65.0-eksbuild.1",<br>  "kube_proxy": "v1.35.3-eksbuild.21",<br>  "vpc_cni": "v1.22.4-eksbuild.3"<br>}</pre> | no |
| <a name="input_application_waf_enabled"></a> [application\_waf\_enabled](#input\_application\_waf\_enabled) | Specifies whether WAF should be provisioned | `bool` | `false` | no |
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | AWS account to deploy resources | `string` | n/a | yes |
| <a name="input_aws_managed_waf_rule_groups"></a> [aws\_managed\_waf\_rule\_groups](#input\_aws\_managed\_waf\_rule\_groups) | n/a | `list(any)` | <pre>[<br>  {<br>    "action": "none",<br>    "name": "AWSManagedRulesAdminProtectionRuleSet",<br>    "priority": 1,<br>    "rules_override_to_count": []<br>  }<br>]</pre> | no |
| <a name="input_cloudfront_waf_enabled"></a> [cloudfront\_waf\_enabled](#input\_cloudfront\_waf\_enabled) | Specifies whether cloudfront for the WAF should be provisioned | `bool` | `false` | no |
| <a name="input_cluster_endpoint_public_access_cidrs"></a> [cluster\_endpoint\_public\_access\_cidrs](#input\_cluster\_endpoint\_public\_access\_cidrs) | CIDRs with access to the EKS cluster. Restricted to customer and ITGix | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_cluster_log_retention_in_days"></a> [cluster\_log\_retention\_in\_days](#input\_cluster\_log\_retention\_in\_days) | Cluster log retention in days | `number` | `14` | no |
| <a name="input_create_elasticache_redis"></a> [create\_elasticache\_redis](#input\_create\_elasticache\_redis) | If a new Elasticache Redis instance needs to be created | `bool` | n/a | yes |
| <a name="input_create_rds"></a> [create\_rds](#input\_create\_rds) | If a new RDS and Proxy needs to be created | `bool` | `false` | no |
| <a name="input_custom_secret_keepers"></a> [custom\_secret\_keepers](#input\_custom\_secret\_keepers) | Map of keepers for the secrets | `map(map(string))` | `{}` | no |
| <a name="input_custom_secrets"></a> [custom\_secrets](#input\_custom\_secrets) | List of custom secrets to create | <pre>list(object({<br>    secret_name      = string<br>    length           = optional(number)<br>    special          = optional(bool)<br>    override_special = optional(string)<br>    keepers          = optional(map(string))<br>    manual           = optional(bool, false)<br>  }))</pre> | n/a | yes |
| <a name="input_ddb_create"></a> [ddb\_create](#input\_ddb\_create) | If a DynomoDB table needs to be created | `bool` | `false` | no |
| <a name="input_ddb_global_create"></a> [ddb\_global\_create](#input\_ddb\_global\_create) | If a DynomoDB global table needs to be created | `bool` | `false` | no |
| <a name="input_ddb_global_table_configuration"></a> [ddb\_global\_table\_configuration](#input\_ddb\_global\_table\_configuration) | List of objects to pass to the module for the creation of the global table. | <pre>list(object({<br>    table_type        = optional(string, "regional")<br>    table_name_suffix = string<br>    hash_key          = string<br>    range_key         = string<br>    hash_key_type     = string<br>    range_key_type    = string<br>    enable_autoscaler = optional(bool, false)<br>    dynamodb_attributes = optional(list(object({<br>      name = string<br>      type = string<br>    })), [])<br>    global_secondary_index_map = optional(list(object({<br>      hash_key           = string<br>      name               = string<br>      projection_type    = string<br>      range_key          = string<br>      non_key_attributes = optional(list(string), [])<br>      read_capacity      = optional(number, 0)<br>      write_capacity     = optional(number, 0)<br>    })), [])<br>    local_secondary_index_map = optional(list(object({<br>      name               = string<br>      projection_type    = string<br>      range_key          = string<br>      non_key_attributes = optional(list(string), [])<br>    })), [])<br>    replicas                      = optional(list(string), [])<br>    tags_enabled                  = optional(bool, true)<br>    billing_mode                  = optional(string, "PAY_PER_REQUEST")<br>    enable_point_in_time_recovery = optional(bool, false)<br>    ttl_enabled                   = optional(bool, false)<br>    ttl_attribute                 = optional(string, "")<br>    deletion_protection_enabled   = optional(bool, true)<br>  }))</pre> | n/a | yes |
| <a name="input_ddb_table_configuration"></a> [ddb\_table\_configuration](#input\_ddb\_table\_configuration) | List of objects to pass to the module for the creation of the table. | <pre>list(object({<br>    table_name_suffix = string<br>    hash_key          = string<br>    range_key         = string<br>    hash_key_type     = string<br>    range_key_type    = string<br>    enable_autoscaler = optional(bool, false)<br>    dynamodb_attributes = optional(list(object({<br>      name = string<br>      type = string<br>    })), [])<br>    global_secondary_index_map = optional(list(object({<br>      hash_key           = string<br>      name               = string<br>      projection_type    = string<br>      range_key          = string<br>      non_key_attributes = optional(list(string), [])<br>      read_capacity      = optional(number, 0)<br>      write_capacity     = optional(number, 0)<br>    })), [])<br>    local_secondary_index_map = optional(list(object({<br>      name               = string<br>      projection_type    = string<br>      range_key          = string<br>      non_key_attributes = optional(list(string), [])<br>    })), [])<br>    replicas                      = optional(list(string), [])<br>    tags_enabled                  = optional(bool, true)<br>    billing_mode                  = optional(string, "PAY_PER_REQUEST")<br>    enable_point_in_time_recovery = optional(bool, false)<br>    ttl_enabled                   = optional(bool, false)<br>    ttl_attribute                 = optional(string, "")<br>    deletion_protection_enabled   = optional(bool, true)<br>  }))</pre> | n/a | yes |
| <a name="input_dns_hosted_zone"></a> [dns\_hosted\_zone](#input\_dns\_hosted\_zone) | Managed R53 Zone ID | `string` | `"Z2INQZ6AA9H9SI"` | no |
| <a name="input_dns_main_domain"></a> [dns\_main\_domain](#input\_dns\_main\_domain) | Domain Managed under the R53 Zone | `string` | `"itgix.eu"` | no |
| <a name="input_dns_domain_names"></a> [dns\_domain\_names](#input\_dns\_domain\_names) | Map of ACM certificate domains and Route53 hosted zone ID for DNS validation. Use an empty string when DNS is not in Route53: no validation records, no aws_acm_certificate_validation (apply will not wait). Use the certificate ARN output and complete validation in your DNS provider before attaching the cert to listeners. | `map(string)` | `{}` | no |
| <a name="input_ec2_spot_service_role"></a> [ec2\_spot\_service\_role](#input\_ec2\_spot\_service\_role) | Configure EC2 spot service role provisioning. | `bool` | `false` | no |
| <a name="input_ecr_create_lifecycle_policy"></a> [ecr\_create\_lifecycle\_policy](#input\_ecr\_create\_lifecycle\_policy) | Determines whether a lifecycle policy will be created | `bool` | `true` | no |
| <a name="input_ecr_manage_registry_scanning_configuration"></a> [ecr\_manage\_registry\_scanning\_configuration](#input\_ecr\_manage\_registry\_scanning\_configuration) | Determines whether the registry scanning configuration will be managed | `bool` | `false` | no |
| <a name="input_ecr_registry_scan_rules"></a> [ecr\_registry\_scan\_rules](#input\_ecr\_registry\_scan\_rules) | One or multiple blocks specifying scanning rules to determine which repository filters are used and at what frequency scanning will occur | `any` | `[]` | no |
| <a name="input_ecr_registry_scan_type"></a> [ecr\_registry\_scan\_type](#input\_ecr\_registry\_scan\_type) | the scanning type to set for the registry. Can be either `ENHANCED` or `BASIC` | `string` | `"BASIC"` | no |
| <a name="input_ecr_repository_encryption_type"></a> [ecr\_repository\_encryption\_type](#input\_ecr\_repository\_encryption\_type) | The encryption type for the repository. Must be one of: `KMS` or `AES256`. Defaults to `AES256` | `string` | `"AES256"` | no |
| <a name="input_ecr_repository_image_scan_on_push"></a> [ecr\_repository\_image\_scan\_on\_push](#input\_ecr\_repository\_image\_scan\_on\_push) | Indicates whether images are scanned after being pushed to the repository (`true`) or not scanned (`false`) | `bool` | `true` | no |
| <a name="input_ecr_repository_image_tag_mutability"></a> [ecr\_repository\_image\_tag\_mutability](#input\_ecr\_repository\_image\_tag\_mutability) | The tag mutability setting for the repository. Must be one of: `MUTABLE` or `IMMUTABLE`. Defaults to `IMMUTABLE` | `string` | `"IMMUTABLE"` | no |
| <a name="input_ecr_repository_name"></a> [ecr\_repository\_name](#input\_ecr\_repository\_name) | The name of the repository | `string` | `""` | no |
| <a name="input_ecr_repository_read_access_arns"></a> [ecr\_repository\_read\_access\_arns](#input\_ecr\_repository\_read\_access\_arns) | The ARNs of the IAM users/roles that have read access to the repository | `list(string)` | `[]` | no |
| <a name="input_ecr_repository_read_write_access_arns"></a> [ecr\_repository\_read\_write\_access\_arns](#input\_ecr\_repository\_read\_write\_access\_arns) | The ARNs of the IAM users/roles that have read/write access to the repository | `list(string)` | `[]` | no |
| <a name="input_ecr_repository_type"></a> [ecr\_repository\_type](#input\_ecr\_repository\_type) | The type of repository to create. Either `public` or `private` | `string` | `"private"` | no |
| <a name="input_eks_ami_type"></a> [eks\_ami\_type](#input\_eks\_ami\_type) | Default AMI type for the EKS worker nodes | `string` | `"AL2_x86_64"` | no |
| <a name="input_eks_aws_auth_roles"></a> [eks\_aws\_auth\_roles](#input\_eks\_aws\_auth\_roles) | n/a | <pre>list(object({<br>    rolearn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_eks_aws_auth_users"></a> [eks\_aws\_auth\_users](#input\_eks\_aws\_auth\_users) | n/a | <pre>list(object({<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_eks_aws_users_path"></a> [eks\_aws\_users\_path](#input\_eks\_aws\_users\_path) | The organizational path of the user used for building the arn , by default it's just / | `string` | `"/"` | no |
| <a name="input_eks_cluster_version"></a> [eks\_cluster\_version](#input\_eks\_cluster\_version) | Desired Kubernetes cluster version | `string` | `"1.35"` | no |
| <a name="input_eks_disk_size"></a> [eks\_disk\_size](#input\_eks\_disk\_size) | Disk size of the root volume attached to the EKS worker nodes | `number` | `50` | no |
| <a name="input_eks_instance_types"></a> [eks\_instance\_types](#input\_eks\_instance\_types) | EC2 instance types for the EKS worker nodes | `list(string)` | <pre>[<br>  "m5a.4xlarge"<br>]</pre> | no |
| <a name="input_eks_kms_key_users"></a> [eks\_kms\_key\_users](#input\_eks\_kms\_key\_users) | A list of IAM ARNs for [key users](https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html#key-policy-default-allow-users) | `list(string)` | `[]` | no |
| <a name="input_eks_ng_capacity_type"></a> [eks\_ng\_capacity\_type](#input\_eks\_ng\_capacity\_type) | capacity type for node group nodes | `string` | `"SPOT"` | no |
| <a name="input_eks_ng_desired_size"></a> [eks\_ng\_desired\_size](#input\_eks\_ng\_desired\_size) | Desired number of the worker nodes in the node group | `number` | `2` | no |
| <a name="input_eks_ng_max_size"></a> [eks\_ng\_max\_size](#input\_eks\_ng\_max\_size) | Maximum number of the worker nodes in the node group | `number` | `5` | no |
| <a name="input_eks_ng_min_size"></a> [eks\_ng\_min\_size](#input\_eks\_ng\_min\_size) | Minimum number of the worker nodes in the node group | `number` | `2` | no |
| <a name="input_eks_volume_iops"></a> [eks\_volume\_iops](#input\_eks\_volume\_iops) | Number of IOPs on the root EBS volumes | `number` | `3000` | no |
| <a name="input_eks_volume_type"></a> [eks\_volume\_type](#input\_eks\_volume\_type) | Type of the root EBS volume attached to the EKS worker nodes | `string` | `"gp3"` | no |
| <a name="input_enable_karpenter"></a> [enable\_karpenter](#input\_enable\_karpenter) | n/a | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment in which the infrastructure is going to be deployed | `string` | n/a | yes |
| <a name="input_force_database_subnet_resize"></a> [force\_database\_subnet\_resize](#input\_force\_database\_subnet\_resize) | Apply the database subnet layout to a VPC that is already provisioned. Kept separate from force\_subnet\_resize because replacing the database subnets replaces the DB subnet group and therefore the RDS cluster and the ElastiCache/Valkey replication groups. Only enable this with a restore plan at hand. | `bool` | `false` | no |
| <a name="input_force_subnet_resize"></a> [force\_subnet\_resize](#input\_force\_subnet\_resize) | Apply the private/public subnet layout to a VPC that is already provisioned. By default the subnets of an existing VPC are read from AWS and kept as they are, so upgrading this template never re-addresses a running environment. Turning this on replaces the private and public subnets, which also replaces every resource pinned to them - most notably the EKS managed node groups and the EFS mount targets. The EKS cluster itself, the NAT gateways' Elastic IPs and the databases are kept. Expect downtime for workloads and delete Kubernetes-managed load balancers before applying, otherwise the old subnets cannot be deleted. | `bool` | `false` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project / client / product to be used in naming convention | `string` | n/a | yes |
| <a name="input_provision_ecr"></a> [provision\_ecr](#input\_provision\_ecr) | n/a | `bool` | `false` | no |
| <a name="input_provision_eks"></a> [provision\_eks](#input\_provision\_eks) | n/a | `bool` | `true` | no |
| <a name="input_provision_sqs"></a> [provision\_sqs](#input\_provision\_sqs) | Enables creation of SQS/SNS resources | `string` | `false` | no |
| <a name="input_provision_vpc"></a> [provision\_vpc](#input\_provision\_vpc) | ######################################################################## #                   Networking Variables                              ## ######################################################################## | `bool` | `true` | no |
| <a name="input_rds_allowed_cidr_blocks"></a> [rds\_allowed\_cidr\_blocks](#input\_rds\_allowed\_cidr\_blocks) | List of CIDRs to be allowed to connect to the DB instance | `list(string)` | `[]` | no |
| <a name="input_rds_config"></a> [rds\_config](#input\_rds\_config) | Configuration for RDS resources | <pre>object({<br>    engine         = string<br>    engine_version = string<br>    engine_mode    = string<br>    cluster_family = string<br>    cluster_size   = number<br>    db_port        = number<br>    db_name        = string<br>  })</pre> | <pre>{<br>  "cluster_family": "aurora-postgresql14",<br>  "cluster_size": 1,<br>  "db_name": "",<br>  "db_port": 5432,<br>  "engine": "aurora-postgresql",<br>  "engine_mode": "provisioned",<br>  "engine_version": "14.5"<br>}</pre> | no |
| <a name="input_rds_default_username"></a> [rds\_default\_username](#input\_rds\_default\_username) | DB username | `string` | `"postgres"` | no |
| <a name="input_rds_extra_credentials"></a> [rds\_extra\_credentials](#input\_rds\_extra\_credentials) | Database extra credentials | <pre>object({<br>    username = string<br>    password = optional(string)<br>    database = string<br>  })</pre> | <pre>{<br>  "database": "demodb",<br>  "username": "demouser"<br>}</pre> | no |
| <a name="input_rds_iam_auth_enabled"></a> [rds\_iam\_auth\_enabled](#input\_rds\_iam\_auth\_enabled) | Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled | `bool` | `false` | no |
| <a name="input_rds_iam_irsa"></a> [rds\_iam\_irsa](#input\_rds\_iam\_irsa) | Enable creation of RDS IAM Policy | `bool` | `false` | no |
| <a name="input_rds_logs_exports"></a> [rds\_logs\_exports](#input\_rds\_logs\_exports) | List of log types to export to cloudwatch. Aurora MySQL: audit, error, general, slowquery. Aurora PostgreSQL: postgresql | `list(string)` | <pre>[<br>  "postgresql"<br>]</pre> | no |
| <a name="input_rds_scaling_config"></a> [rds\_scaling\_config](#input\_rds\_scaling\_config) | The minimum and maximum number of Aurora capacity units (ACUs) for a DB instance | <pre>object({<br>    min_capacity = number<br>    max_capacity = number<br>  })</pre> | <pre>{<br>  "max_capacity": 2,<br>  "min_capacity": 0.5<br>}</pre> | no |
| <a name="input_redis_allowed_cidr_blocks"></a> [redis\_allowed\_cidr\_blocks](#input\_redis\_allowed\_cidr\_blocks) | List of CIDRs allowed on Redis security group rules | `list(any)` | n/a | yes |
| <a name="input_redis_allowed_security_group_ids"></a> [redis\_allowed\_security\_group\_ids](#input\_redis\_allowed\_security\_group\_ids) | A list of IDs of Security Groups to allow access to the security group created by this module on Redis port. | `list(string)` | n/a | yes |
| <a name="input_redis_automatic_failover_enabled"></a> [redis\_automatic\_failover\_enabled](#input\_redis\_automatic\_failover\_enabled) | Automatic failover (Not available for T1/T2 instances) | `bool` | `true` | no |
| <a name="input_redis_cloudwatch_logs_enabled"></a> [redis\_cloudwatch\_logs\_enabled](#input\_redis\_cloudwatch\_logs\_enabled) | Indicates whether you want to enable or disable streaming broker logs to Cloudwatch Logs. | `bool` | n/a | yes |
| <a name="input_redis_cluster_mode_enabled"></a> [redis\_cluster\_mode\_enabled](#input\_redis\_cluster\_mode\_enabled) | Flag to enable/disable cluster mode | `bool` | n/a | yes |
| <a name="input_redis_cluster_size"></a> [redis\_cluster\_size](#input\_redis\_cluster\_size) | Number of nodes in cluster. Ignored when redis\_cluster\_mode\_enabled == true | `number` | n/a | yes |
| <a name="input_redis_engine_version"></a> [redis\_engine\_version](#input\_redis\_engine\_version) | Redis engine version | `string` | n/a | yes |
| <a name="input_redis_family"></a> [redis\_family](#input\_redis\_family) | Redis family | `string` | n/a | yes |
| <a name="input_redis_instance_type"></a> [redis\_instance\_type](#input\_redis\_instance\_type) | Elastic cache instance type | `string` | n/a | yes |
| <a name="input_redis_multi_az_enabled"></a> [redis\_multi\_az\_enabled](#input\_redis\_multi\_az\_enabled) | Flag to enable/disable Multiple AZs | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region to deploy to | `string` | n/a | yes |
| <a name="input_resources_tags"></a> [resources\_tags](#input\_resources\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_sns_topics"></a> [sns\_topics](#input\_sns\_topics) | n/a | `map(any)` | n/a | yes |
| <a name="input_sqs_iam_role_name"></a> [sqs\_iam\_role\_name](#input\_sqs\_iam\_role\_name) | If not empty, created IAM Role for usage with SQS for a more granular access | `string` | `""` | no |
| <a name="input_sqs_queues"></a> [sqs\_queues](#input\_sqs\_queues) | n/a | `map(any)` | n/a | yes |
| <a name="input_sqs_username"></a> [sqs\_username](#input\_sqs\_username) | If not empty, created IAM User for usage with SQS for a more granular access | `string` | `""` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR of VPC to be used by Resale common resources | `string` | `""` | no |
| <a name="input_vpc_database_subnets"></a> [vpc\_database\_subnets](#input\_vpc\_database\_subnets) | Database (RDS / ElastiCache) subnet layout inside var.vpc\_cidr. The defaults intentionally match the ranges used since the first release of this template so databases are never moved. | <pre>object({<br>    newbits = optional(number, 8)<br>    offsets = optional(list(number), [24, 25, 26])<br>    cidrs   = optional(list(string), [])<br>  })</pre> | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | External VPC ID | `string` | `""` | no |
| <a name="input_vpc_private_route_table_ids"></a> [vpc\_private\_route\_table\_ids](#input\_vpc\_private\_route\_table\_ids) | External VPC private route table IDs | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_vpc_private_subnet_ids"></a> [vpc\_private\_subnet\_ids](#input\_vpc\_private\_subnet\_ids) | External VPC private subnet IDs | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_vpc_private_subnets"></a> [vpc\_private\_subnets](#input\_vpc\_private\_subnets) | Private (EKS node / pod) subnet layout inside var.vpc\_cidr. Defaults to three /21 subnets on a /16 VPC. Set cidrs to pin exact ranges instead. | <pre>object({<br>    newbits = optional(number, 5)<br>    offsets = optional(list(number), [0, 1, 2])<br>    cidrs   = optional(list(string), [])<br>  })</pre> | `{}` | no |
| <a name="input_vpc_public_subnet_ids"></a> [vpc\_public\_subnet\_ids](#input\_vpc\_public\_subnet\_ids) | External VPC public subnet IDs | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_vpc_public_subnets"></a> [vpc\_public\_subnets](#input\_vpc\_public\_subnets) | Public (load balancer / NAT) subnet layout inside var.vpc\_cidr. Defaults to three /23 subnets on a /16 VPC. Set cidrs to pin exact ranges instead. | <pre>object({<br>    newbits = optional(number, 7)<br>    offsets = optional(list(number), [14, 15, 16])<br>    cidrs   = optional(list(string), [])<br>  })</pre> | `{}` | no |
| <a name="input_vpc_single_nat_gateway"></a> [vpc\_single\_nat\_gateway](#input\_vpc\_single\_nat\_gateway) | Wether to use just a single NAT gateway instead of a NAT GW per availability zone for HA and as recommended. This might be suitable for dev/test environments | `bool` | `false` | no |
| <a name="input_waf_default_action"></a> [waf\_default\_action](#input\_waf\_default\_action) | allow or block - default action of WAF when a request hasn't matched any rules | `string` | `"allow"` | no |
| <a name="input_waf_log_retention_days"></a> [waf\_log\_retention\_days](#input\_waf\_log\_retention\_days) | n/a | `any` | n/a | yes |
| <a name="input_waf_logging_enabled"></a> [waf\_logging\_enabled](#input\_waf\_logging\_enabled) | n/a | `any` | n/a | yes |
| <a name="input_waf_sampled_requests_enabled"></a> [waf\_sampled\_requests\_enabled](#input\_waf\_sampled\_requests\_enabled) | n/a | `any` | n/a | yes |
| <a name="input_waf_webacl_cloudwatch_enabled"></a> [waf\_webacl\_cloudwatch\_enabled](#input\_waf\_webacl\_cloudwatch\_enabled) | n/a | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_az1"></a> [az1](#output\_az1) | n/a |
| <a name="output_az2"></a> [az2](#output\_az2) | n/a |
| <a name="output_az3"></a> [az3](#output\_az3) | n/a |
| <a name="output_custom_secret_arns"></a> [custom\_secret\_arns](#output\_custom\_secret\_arns) | n/a |
| <a name="output_custom_secret_names"></a> [custom\_secret\_names](#output\_custom\_secret\_names) | n/a |
| <a name="output_custom_secret_values"></a> [custom\_secret\_values](#output\_custom\_secret\_values) | n/a |
| <a name="output_custom_secret_versions"></a> [custom\_secret\_versions](#output\_custom\_secret\_versions) | n/a |
| <a name="output_ecr_repository_arn"></a> [ecr\_repository\_arn](#output\_ecr\_repository\_arn) | Full ARN of the repository |
| <a name="output_ecr_repository_name"></a> [ecr\_repository\_name](#output\_ecr\_repository\_name) | Name of the repository |
| <a name="output_ecr_repository_registry_id"></a> [ecr\_repository\_registry\_id](#output\_ecr\_repository\_registry\_id) | The registry ID where the repository was created |
| <a name="output_ecr_repository_url"></a> [ecr\_repository\_url](#output\_ecr\_repository\_url) | The URL of the repository (in the form `aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName`) |
| <a name="output_eks_cluster_arn"></a> [eks\_cluster\_arn](#output\_eks\_cluster\_arn) | n/a |
| <a name="output_eks_cluster_endpoint"></a> [eks\_cluster\_endpoint](#output\_eks\_cluster\_endpoint) | n/a |
| <a name="output_eks_cluster_name"></a> [eks\_cluster\_name](#output\_eks\_cluster\_name) | n/a |
| <a name="output_eks_irsa_external_dns_arn"></a> [eks\_irsa\_external\_dns\_arn](#output\_eks\_irsa\_external\_dns\_arn) | n/a |
| <a name="output_fluentbit_sa_role_arn"></a> [fluentbit\_sa\_role\_arn](#output\_fluentbit\_sa\_role\_arn) | IAM Role ARN for Fluent Bit Service Account |
| <a name="output_irsa_rds_role_arn"></a> [irsa\_rds\_role\_arn](#output\_irsa\_rds\_role\_arn) | ARN of the IAM Role for access to rds database |
| <a name="output_karpenter_queue_name"></a> [karpenter\_queue\_name](#output\_karpenter\_queue\_name) | Interruption queue name for karpenter |
| <a name="output_karpenter_sa_role"></a> [karpenter\_sa\_role](#output\_karpenter\_sa\_role) | IRSA role for karpenter SA |
| <a name="output_node_iam_role_name"></a> [node\_iam\_role\_name](#output\_node\_iam\_role\_name) | n/a |
| <a name="output_node_security_group"></a> [node\_security\_group](#output\_node\_security\_group) | n/a |
| <a name="output_rds_cluster_arn"></a> [rds\_cluster\_arn](#output\_rds\_cluster\_arn) | The RDS Cluster ARN |
| <a name="output_rds_cluster_endpoint"></a> [rds\_cluster\_endpoint](#output\_rds\_cluster\_endpoint) | RDS Cluster endpoint |
| <a name="output_rds_cluster_identifier"></a> [rds\_cluster\_identifier](#output\_rds\_cluster\_identifier) | The RDS Cluster Identifier |
| <a name="output_rds_credentials_kms_key_arn"></a> [rds\_credentials\_kms\_key\_arn](#output\_rds\_credentials\_kms\_key\_arn) | RDS Credentials kms key arn |
| <a name="output_rds_extra_credentials_secret_arn"></a> [rds\_extra\_credentials\_secret\_arn](#output\_rds\_extra\_credentials\_secret\_arn) | RDS Extra Credentials Secret ARN |
| <a name="output_rds_extra_credentials_secret_name"></a> [rds\_extra\_credentials\_secret\_name](#output\_rds\_extra\_credentials\_secret\_name) | RDS Extra Credentials Secret Name |
| <a name="output_rds_iam_auth_irsa_arn"></a> [rds\_iam\_auth\_irsa\_arn](#output\_rds\_iam\_auth\_irsa\_arn) | n/a |
| <a name="output_rds_master_credentials_secret_arn"></a> [rds\_master\_credentials\_secret\_arn](#output\_rds\_master\_credentials\_secret\_arn) | RDS Master Credentials Secret ARN |
| <a name="output_rds_master_credentials_secret_name"></a> [rds\_master\_credentials\_secret\_name](#output\_rds\_master\_credentials\_secret\_name) | RDS Master Credentials Secret Name |
| <a name="output_redis_primary_endpoint_address"></a> [redis\_primary\_endpoint\_address](#output\_redis\_primary\_endpoint\_address) | Redis primary or configuration endpoint, whichever is appropriate for the given cluster mode |
| <a name="output_redis_reader_endpoint_address"></a> [redis\_reader\_endpoint\_address](#output\_redis\_reader\_endpoint\_address) | The address of the endpoint for the reader node in the replication group, if the cluster mode is disabled. |
| <a name="output_subnet1"></a> [subnet1](#output\_subnet1) | n/a |
| <a name="output_subnet2"></a> [subnet2](#output\_subnet2) | n/a |
| <a name="output_subnet3"></a> [subnet3](#output\_subnet3) | n/a |
| <a name="output_waf_webacl_arn"></a> [waf\_webacl\_arn](#output\_waf\_webacl\_arn) | RDS Credentials kms key arn |

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

  aws_region   = var.region
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
| <a name="input_region"></a> [aws\_region](#input\_aws\_region) | AWS region to deploy to | `string` | n/a | yes |
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
