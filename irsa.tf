##########################
#IRSA for RDS IAM Auth   #
##########################
module "rds_iam_auth" {

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  count   = var.rds_iam_irsa ? 1 : 0
  version = "5.34.0"
  
  assume_role_condition_test     = "StringLike"
  create_role = true
  role_name   = "rds-iam-auth-${local.eks_name}"
  role_policy_arns = {
    rds_iam_auth_policy = aws_iam_policy.rds_iam_auth.arn
    policy_sqs = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
    policy_sqs = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
    policy_kmspw = "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"
  }
  oidc_providers = {
    main = {
      provider_arn               = module.eks[0].oidc_provider_arn
      namespace_service_accounts = ["*:*"]
    }
  }
}



resource "aws_iam_policy" "rds_iam_auth" {

  name_prefix = "rds_iam_auth"
  description = "Policy for ServiceAccounts allowing RDS_IAM access for cluster ${local.eks_name}"
  policy      = <<EOT
{
    "Statement": [
        {
            "Action": [
                "rds-db:connect",
                "rds-db:*"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:rds-db:${var.region}:${var.aws_account_id}:dbuser:*/*",
            "Sid": "AllowRDSiamAccess"
        }
    ],
    "Version": "2012-10-17"
}
EOT
}


##########################
#IRSA for ITGix ADP agent   #
##########################
module "irsa_itgix_adp_agent" {

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.34.0"

  assume_role_condition_test     = "StringLike"
  create_role = true
  role_name   = "irsa-itgix-adp-${local.eks_name}"
  role_policy_arns = {
    itgix_adp_agent_policy = aws_iam_policy.irsa_itgix_adp_agent.arn
  }
  oidc_providers = {
    main = {
      provider_arn               = module.eks[0].oidc_provider_arn
      namespace_service_accounts = ["*:*"]
    }
  }
}

resource "aws_iam_policy" "irsa_itgix_adp_agent" {

  name_prefix = "irsa_itgix_adp_agent"
  description = "Policy for ServiceAccounts allowing calls to AWS metering API for cluster ${local.eks_name}"
  policy      = <<EOT
{
    "Statement": [
        {
            "Action": [
                "aws-marketplace:RegisterUsage",
                "aws-marketplace:MeterUsage"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ],
    "Version": "2012-10-17"
}
EOT
}

#############################################
#IRSA for fluent-bit access to cloudwatch   #
#############################################
module "irsa_fluentbit_cloudwatch" {

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.34.0"

  assume_role_condition_test     = "StringLike"
  create_role = true
  role_name   = "irsa-fluentbit-cloudwatch-${local.eks_name}"
  role_policy_arns = {
    aws_managed_policy = "arn:aws:iam::aws:policy/service-role/AWSAppSyncPushToCloudWatchLogs"
  }
  oidc_providers = {
    main = {
      provider_arn               = module.eks[0].oidc_provider_arn
      namespace_service_accounts = ["fluent-bit:fluent-bit"]
    }
  }
}