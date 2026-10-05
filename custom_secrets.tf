module "custom_secrets_password_module" {
  source = "git::https://github.com/itgix/tf-module-awssm-passgen.git?ref=add-support-for-tags"

  custom_secrets = var.custom_secrets

  secret_name_prefix = "${local.aws_regions_short[var.region]}-${var.environment}-${var.project_name}-"
  secret_keepers     = var.custom_secret_keepers

  tags = local.aws_default_tags
}
