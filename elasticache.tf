module "elasticache" {

  source  = "git::git@gitlab.itgix.com:rnd/app-platform/iac-modules/aws-elasticache-redis.git?ref=main"

  count = var.create_elasticache_redis ? 1 : 0

  aws_region                 = var.region
  environment                = var.environment
  product_name               = var.project_name

  vpc_id                     = var.vpc_id
  subnet_ids                 = var.vpc_private_subnet_ids
  cluster_size               = var.redis_cluster_size
  instance_type              = var.redis_instance_type
  automatic_failover_enabled = var.redis_automatic_failover_enabled
  engine_version             = var.redis_engine_version
  family                     = var.redis_family
  allowed_cidr_blocks        = var.redis_allowed_cidr_blocks
  allowed_security_group_ids = var.redis_allowed_security_group_ids

}