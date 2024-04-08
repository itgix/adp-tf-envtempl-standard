environment    = "stg"
region         = "eu-west-1"
project_name   = "igxadp"
customer_name  = "itgix"
aws_account_id = "722377226063"

# Networking
provision_vpc       = true
vpc_cidr            = "10.51.0.0/16"
vpc_id              = ""
vpc_private_subnet_ids = ["", "", ""]
vpc_public_subnet_ids = ["", "", ""]

# EKS
provision_eks       = true
eks_cluster_version = "1.29"
eks_instance_types  = ["m5a.large" ]

addons_versions = {
  coredns    = "v1.11.1-eksbuild.4"
  kube_proxy = "v1.29.0-eksbuild.1"
  vpc_cni    = "v1.16.0-eksbuild.1"
  ebs_csi    = "v1.27.0-eksbuild.1"
}

eks_aws_auth_roles = [
  {
    rolearn  = "eks-ec1-dev-itgix-role"
    username = "system:node:{{EC2PrivateDNSName}}"
    groups   = ["system:masters"]
  }
  #### Example for SSO ####
  # {
  #   rolearn  = "aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_4c46618bf79ed514"
  #   username = "eks-admin"
  #   groups   = ["system:masters"]
  # }
]

eks_aws_auth_users = [
  {
    username = "ytodorov"
    groups   = ["system:masters"]
  },
  {
    username = "bdimitrov"
    groups   = ["system:masters"]
  },
  {
    username = "aalexiev"
    groups   = ["system:masters"]
  },
  {
    username = "vdimitrov"
    groups   = ["system:masters"]
  },
  {
    username = "dmilanov"
    groups   = ["system:masters"]
  },
  {
    username = "nkazakov"
    groups   = ["system:masters"]
  },
  {
    username = "htonev"
    groups   = ["system:masters"]
  },
  {
    username = "mvukadinoff"
    groups   = ["system:masters"]
  }
]


eks_kms_key_users = [
  "arn:aws:iam::722377226063:user/users/mvukadinoff",
  "arn:aws:iam::722377226063:user/users/vdimitrov"
]
create_rds = true
rds_extra_credentials = {
  "username" = "demouser"
  "database" = "demodb"
}

