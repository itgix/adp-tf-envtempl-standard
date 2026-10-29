module "custom_secrets_password_module" {
  source = "git::https://github.com/itgix/tf-module-awssm-passgen.git?ref=v1.1.1"

  custom_secrets = var.custom_secrets

  secret_name_prefix = "${local.aws_regions_short[var.region]}-${var.environment}-${var.project_name}-"

  tags = local.aws_default_tags
}
