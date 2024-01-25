data "aws_availability_zones" "available" {
  state = "available"
}

module "common_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.18"

  name                 = local.vpc_name
  cidr                 = var.vpc_cidr
  azs                  = data.aws_availability_zones.available.names
  enable_dns_hostnames = true

  ## Subnets
  private_subnets = [
    cidrsubnet(var.vpc_cidr, 8, 0),
    cidrsubnet(var.vpc_cidr, 8, 1),
    cidrsubnet(var.vpc_cidr, 8, 2)
  ]
  public_subnets = [
    cidrsubnet(var.vpc_cidr, 8, 3),
    cidrsubnet(var.vpc_cidr, 8, 4),
    cidrsubnet(var.vpc_cidr, 8, 5)
  ]
  database_subnets = [
    cidrsubnet(var.vpc_cidr, 8, 6),
    cidrsubnet(var.vpc_cidr, 8, 7),
    cidrsubnet(var.vpc_cidr, 8, 8)
  ]
  database_subnet_assign_ipv6_address_on_creation = false
  map_public_ip_on_launch                         = false
}