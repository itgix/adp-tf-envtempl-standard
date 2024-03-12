environment    = "dev"
aws_region     = "eu-central-1"
project_name   = "itgix"
aws_account_id = "767398095708"
aws_default_tags = {
  "platform:environment" = "Development"
  "platform:customer"    = "Itgix"
}

# Networking
provision_vpc       = false
vpc_cidr            = "10.1.0.0/16"
allowed_cidr_blocks = ["10.1.0.0/16"]
vpc_id              = "vpc-00eee93eccbb7452f"
vpc_private_subnet_ids = ["subnet-044cb4e0e119a4f6d", "subnet-0a284d7b2f9a75419", "subnet-0ac621dfdfb66741a"]
vpc_public_subnet_ids = ["subnet-07da0108356fbd63c", "subnet-0549f609b51096fa4", "subnet-0c0e4a26397799d29"]

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
      rolearn  = "arn:aws:iam::767398095708:role/eks-ec1-dev-itgix-role"
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::767398095708:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_98652b0fb3de153c"
      username = "eks-admin"
      groups   = ["system:masters"]
    }
  ]

# eks_aws_auth_users = [
#     {
#       userarn  = "arn:aws:iam::722377226063:user/users/ytodorov"
#       username = "ytodorov"
#       groups   = ["system:masters"]
#     },
#     {
#       userarn  = "arn:aws:iam::722377226063:user/users/bdimitrov"
#       username = "bdimitrov"
#       groups   = ["system:masters"]
#     },
#     {
#       userarn  = "arn:aws:iam::722377226063:user/users/aalexiev"
#       username = "aalexiev"
#       groups   = ["system:masters"]
#     },
#     {
#       userarn  = "arn:aws:iam::722377226063:user/users/vdimitrov"
#       username = "vdimitrov"
#       groups   = ["system:masters"]
#     },
#     {
#       userarn  = "arn:aws:iam::722377226063:user/users/dmilanov"
#       username = "dmilanov"
#       groups   = ["system:masters"]
#     },
#     {
#       userarn  = "arn:aws:iam::722377226063:user/users/nkazakov"
#       username = "nkazakov"
#       groups   = ["system:masters"]
#     },
#     {
#       userarn  = "arn:aws:iam::722377226063:user/users/htonev"
#       username = "htonev"
#       groups   = ["system:masters"]
#     },
#     {
#       userarn  = "arn:aws:iam::722377226063:user/users/mvukadinoff"
#       username = "mvukadinoff"
#       groups   = ["system:masters"]
#     }
#   ]

# eks_kms_key_users = [
#   "arn:aws:iam::722377226063:user/users/mvukadinoff",
#   "arn:aws:iam::722377226063:user/users/vdimitrov"
#   ]
