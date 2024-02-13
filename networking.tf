data "aws_availability_zones" "available" {
  state = "available"
}

module "common_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.5.1"

  name                   = local.vpc_name
  cidr                   = var.vpc_cidr
  azs                    = data.aws_availability_zones.available.names
  enable_dns_hostnames   = true
  enable_dns_support     = true
  enable_ipv6            = false
  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  ## Subnets
  private_subnets = [
    cidrsubnet(var.vpc_cidr, 10, 0),
    cidrsubnet(var.vpc_cidr, 10, 4),
    cidrsubnet(var.vpc_cidr, 10, 8)
  ]
  public_subnets = [
    cidrsubnet(var.vpc_cidr, 10, 12),
    cidrsubnet(var.vpc_cidr, 10, 16),
    cidrsubnet(var.vpc_cidr, 10, 20)
  ]
  database_subnets = [
    cidrsubnet(var.vpc_cidr, 8, 24),
    cidrsubnet(var.vpc_cidr, 8, 25),
    cidrsubnet(var.vpc_cidr, 8, 26)
  ]
  database_subnet_assign_ipv6_address_on_creation = false
  map_public_ip_on_launch                         = false

  public_subnet_tags = {
    "kubernetes.io/role/elb"                  = 1
    "kubernetes.io/cluster/${local.eks_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"         = 1
    "kubernetes.io/cluster/${local.eks_name}" = "shared"
  }

  create_database_subnet_route_table = true

  tags = var.aws_default_tags

}

resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = try(module.common_vpc.vpc_id, "")
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.common_vpc.private_route_table_ids
  tags              = merge(var.aws_default_tags, { Name = "${local.vpc_s3_endpoint_name}" })
}
