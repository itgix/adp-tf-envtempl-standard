environment    = "dev"
aws_region     = "eu-west-1"
project_name   = "itgix"
aws_account_id = "722377226063"
aws_default_tags = {
  "platform:environment" = "Development"
  "platform:customer"    = "Itgix"
}

# Networking
vpc_cidr            = "10.50.0.0/16"
allowed_cidr_blocks = ["10.50.0.0/16"]

# EKS
provision_eks       = true
eks_cluster_version = "1.29"

addons_versions = {
  coredns    = "v1.11.1-eksbuild.4"
  kube_proxy = "v1.29.0-eksbuild.1"
  vpc_cni    = "v1.16.0-eksbuild.1"
  ebs_csi    = "v1.27.0-eksbuild.1"
}

eks_aws_auth_users = [
    {
      userarn  = "arn:aws:iam::722377226063:user/ytodorov"
      username = "ytodorov"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::722377226063:user/bdimitrov"
      username = "bdimitrov"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::722377226063:user/aalexiev"
      username = "aalexiev"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::722377226063:user/vdimitrov"
      username = "vdimitrov"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::722377226063:user/dmilanov"
      username = "dmilanov"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::722377226063:user/nkazakov"
      username = "nkazakov"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::722377226063:user/htonev"
      username = "htonev"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::722377226063:user/mvukadinoff"
      username = "mvukadinoff"
      groups   = ["system:masters"]
    }
  ]
