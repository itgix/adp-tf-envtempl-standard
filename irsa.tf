##########################
#IRSA for RDS IAM Auth   #
##########################
module "rds_iam_auth" {

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  count   = var.rds_iam_irsa ? 1 : 0
  version = "5.34.0"

  assume_role_condition_test = "StringLike"
  create_role                = true
  role_name                  = "rds-iam-auth-${local.eks_name}"
  role_policy_arns = {
    rds_iam_auth_policy = aws_iam_policy.rds_iam_auth.arn
    policy_sqs          = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
    policy_sqs          = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
    policy_kmspw        = "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"
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

  assume_role_condition_test = "StringLike"
  create_role                = true
  role_name                  = "irsa-itgix-adp-${local.eks_name}"
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

  assume_role_condition_test = "StringLike"
  create_role                = true
  role_name                  = "irsa-fluentbit-cloudwatch-${local.eks_name}"
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

#############################################
#IRSA for Karpenter                         #
#############################################
resource "aws_iam_policy" "irsa_karpenter" {

  name_prefix = "irsa_karpenter"
  description = "Policy for Karpenter ServiceAccounts for cluster ${local.eks_name}"
  policy      = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowScopedEC2InstanceAccessActions",
      "Effect": "Allow",
      "Action": [
        "ec2:RunInstances",
        "ec2:CreateFleet"
      ],
      "Resource": [
        "arn:aws:ec2:${var.region}::image/*",
        "arn:aws:ec2:${var.region}::snapshot/*",
        "arn:aws:ec2:${var.region}:*:security-group/*",
        "arn:aws:ec2:${var.region}:*:subnet/*",
        "arn:aws:ec2:${var.region}:*:capacity-reservation/*"
      ]
    },
    {
      "Sid": "AllowScopedEC2LaunchTemplateAccessActions",
      "Effect": "Allow",
      "Action": [
        "ec2:RunInstances",
        "ec2:CreateFleet"
      ],
      "Resource": "arn:aws:ec2:${var.region}:*:launch-template/*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/kubernetes.io/cluster/${local.eks_name}": "owned"
        },
        "StringLike": {
          "aws:ResourceTag/karpenter.sh/nodepool": "*"
        }
      }
    },
    {
      "Sid": "AllowScopedEC2InstanceActionsWithTags",
      "Effect": "Allow",
      "Action": [
        "ec2:RunInstances",
        "ec2:CreateFleet",
        "ec2:CreateLaunchTemplate"
      ],
      "Resource": [
        "arn:aws:ec2:${var.region}:*:fleet/*",
        "arn:aws:ec2:${var.region}:*:instance/*",
        "arn:aws:ec2:${var.region}:*:volume/*",
        "arn:aws:ec2:${var.region}:*:network-interface/*",
        "arn:aws:ec2:${var.region}:*:launch-template/*",
        "arn:aws:ec2:${var.region}:*:spot-instances-request/*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestTag/kubernetes.io/cluster/${local.eks_name}": "owned",
          "aws:RequestTag/eks:eks-cluster-name": "${local.eks_name}"
        },
        "StringLike": {
          "aws:RequestTag/karpenter.sh/nodepool": "*"
        }
      }
    },
    {
      "Sid": "AllowScopedResourceCreationTagging",
      "Effect": "Allow",
      "Action": "ec2:CreateTags",
      "Resource": [
        "arn:aws:ec2:${var.region}:*:fleet/*",
        "arn:aws:ec2:${var.region}:*:instance/*",
        "arn:aws:ec2:${var.region}:*:volume/*",
        "arn:aws:ec2:${var.region}:*:network-interface/*",
        "arn:aws:ec2:${var.region}:*:launch-template/*",
        "arn:aws:ec2:${var.region}:*:spot-instances-request/*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:RequestTag/kubernetes.io/cluster/${local.eks_name}": "owned",
          "aws:RequestTag/eks:eks-cluster-name": "${local.eks_name}",
          "ec2:CreateAction": [
            "RunInstances",
            "CreateFleet",
            "CreateLaunchTemplate"
          ]
        },
        "StringLike": {
          "aws:RequestTag/karpenter.sh/nodepool": "*"
        }
      }
    },
    {
      "Sid": "AllowScopedResourceTagging",
      "Effect": "Allow",
      "Action": "ec2:CreateTags",
      "Resource": "arn:aws:ec2:${var.region}:*:instance/*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/kubernetes.io/cluster/${local.eks_name}": "owned"
        },
        "StringLike": {
          "aws:ResourceTag/karpenter.sh/nodepool": "*"
        },
        "StringEqualsIfExists": {
          "aws:RequestTag/eks:eks-cluster-name": "${local.eks_name}"
        },
        "ForAllValues:StringEquals": {
          "aws:TagKeys": [
            "eks:eks-cluster-name",
            "karpenter.sh/nodeclaim",
            "Name"
          ]
        }
      }
    },
    {
      "Sid": "AllowScopedDeletion",
      "Effect": "Allow",
      "Action": [
        "ec2:TerminateInstances",
        "ec2:DeleteLaunchTemplate"
      ],
      "Resource": [
        "arn:aws:ec2:${var.region}:*:instance/*",
        "arn:aws:ec2:${var.region}:*:launch-template/*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/kubernetes.io/cluster/${local.eks_name}": "owned"
        },
        "StringLike": {
          "aws:ResourceTag/karpenter.sh/nodepool": "*"
        }
      }
    },
    {
      "Sid": "AllowRegionalReadActions",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeCapacityReservations",
        "ec2:DescribeImages",
        "ec2:DescribeInstances",
        "ec2:DescribeInstanceTypeOfferings",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeLaunchTemplates",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSpotPriceHistory",
        "ec2:DescribeSubnets"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "${var.region}"
        }
      }
    },
    {
      "Sid": "AllowSSMReadActions",
      "Effect": "Allow",
      "Action": "ssm:GetParameter",
      "Resource": "arn:aws:ssm:${var.region}::parameter/aws/service/*"
    },
    {
      "Sid": "AllowPricingReadActions",
      "Effect": "Allow",
      "Action": "pricing:GetProducts",
      "Resource": "*"
    },
    {
      "Sid": "AllowInterruptionQueueActions",
      "Effect": "Allow",
      "Action": [
        "sqs:DeleteMessage",
        "sqs:GetQueueUrl",
        "sqs:ReceiveMessage"
      ],
      "Resource": "arn:aws:sqs:${var.region}:${var.aws_account_id}:queue-${var.region}-${var.environment}-karpenter"
    },
    {
      "Sid": "AllowPassingInstanceRole",
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "arn:aws:iam::${var.aws_account_id}:role/${local.eks_name}-*",
      "Condition": {
        "StringEquals": {
          "iam:PassedToService": [
            "ec2.amazonaws.com",
            "ec2.amazonaws.com.cn"
          ]
        }
      }
    },
    {
      "Sid": "AllowScopedInstanceProfileCreationActions",
      "Effect": "Allow",
      "Action": "iam:CreateInstanceProfile",
      "Resource": "arn:aws:iam::${var.aws_account_id}:instance-profile/*",
      "Condition": {
        "StringEquals": {
          "aws:RequestTag/kubernetes.io/cluster/eks-ew1-stg-itgixadp": "owned",
          "aws:RequestTag/eks:eks-cluster-name": "${local.eks_name}",
          "aws:RequestTag/topology.kubernetes.io/region": "${var.region}"
        },
        "StringLike": {
          "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass": "*"
        }
      }
    },
    {
      "Sid": "AllowScopedInstanceProfileTagActions",
      "Effect": "Allow",
      "Action": "iam:TagInstanceProfile",
      "Resource": "arn:aws:iam::${var.aws_account_id}:instance-profile/*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/kubernetes.io/cluster/${local.eks_name}": "owned",
          "aws:ResourceTag/topology.kubernetes.io/region": "${var.region}",
          "aws:RequestTag/kubernetes.io/cluster/${local.eks_name}": "owned",
          "aws:RequestTag/eks:eks-cluster-name": "${local.eks_name}",
          "aws:RequestTag/topology.kubernetes.io/region": "${var.region}"
        },
        "StringLike": {
          "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass": "*",
          "aws:RequestTag/karpenter.k8s.aws/ec2nodeclass": "*"
        }
      }
    },
    {
      "Sid": "AllowScopedInstanceProfileActions",
      "Effect": "Allow",
      "Action": [
        "iam:AddRoleToInstanceProfile",
        "iam:RemoveRoleFromInstanceProfile",
        "iam:DeleteInstanceProfile"
      ],
      "Resource": "arn:aws:iam::${var.aws_account_id}:instance-profile/*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/kubernetes.io/cluster/${local.eks_name}": "owned",
          "aws:ResourceTag/topology.kubernetes.io/region": "${var.region}"
        },
        "StringLike": {
          "aws:ResourceTag/karpenter.k8s.aws/ec2nodeclass": "*"
        }
      }
    },
    {
      "Sid": "AllowInstanceProfileReadActions",
      "Effect": "Allow",
      "Action": "iam:GetInstanceProfile",
      "Resource": "arn:aws:iam::${var.aws_account_id}:instance-profile/*"
    },
    {
      "Sid": "AllowUnscopedInstanceProfileListAction",
      "Effect": "Allow",
      "Action": "iam:ListInstanceProfiles",
      "Resource": "*"
    },
    {
      "Sid": "AllowAPIServerEndpointDiscovery",
      "Effect": "Allow",
      "Action": "eks:DescribeCluster",
      "Resource": "arn:aws:eks:${var.region}:${var.aws_account_id}:cluster/${local.eks_name}"
    }
  ]
}
EOT
}

module "irsa_karpenter" {

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.34.0"

  assume_role_condition_test = "StringEquals"
  create_role                = true
  role_name                  = "KarpenterIRSA-${local.eks_name}"
  role_policy_arns = {
    itgix_adp_agent_policy = aws_iam_policy.irsa_karpenter.arn
  }
  oidc_providers = {
    main = {
      provider_arn               = module.eks[0].oidc_provider_arn
      namespace_service_accounts = ["${local.karpenter_namespace}:karpenter"]
    }
  }
}