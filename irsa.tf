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
