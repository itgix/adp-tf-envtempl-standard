module "ecr" {
  source                = "git::git@gitlab.itgix.com:rnd/app-platform/iac-modules/elastic-container-registry.git?ref=v1.0.0"
  ecr_create_repository = var.provision_ecr

  aws_region   = var.region
  environment  = var.environment
  project_name = var.project_name

  ecr_repository_name                   = var.ecr_repository_name
  ecr_repository_type                   = var.ecr_repository_type
  ecr_repository_read_write_access_arns = var.ecr_repository_read_write_access_arns
  ecr_repository_read_access_arns       = var.ecr_repository_read_access_arns
  ecr_repository_encryption_type        = var.ecr_repository_encryption_type

  ecr_repository_image_scan_on_push   = var.ecr_repository_image_scan_on_push
  ecr_repository_image_tag_mutability = var.ecr_repository_image_tag_mutability

  ecr_manage_registry_scanning_configuration = var.ecr_manage_registry_scanning_configuration
  ecr_registry_scan_type                     = var.ecr_registry_scan_type
  ecr_registry_scan_rules                    = var.ecr_registry_scan_rules

  ecr_create_lifecycle_policy = var.ecr_create_lifecycle_policy

  resources_tags = local.aws_default_tags

}
