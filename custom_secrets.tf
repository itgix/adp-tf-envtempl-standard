module "custom_secrets_password_module" {
  source = "git@github.com:iroussev-itgix/tf-module-awssm-passgen.git?ref=feat/support-custom-secret-values"

  custom_secrets = var.custom_secrets

  secret_name_prefix = "${local.aws_regions_short[var.region]}-${var.environment}-${var.project_name}-"
  secret_keepers     = var.custom_secret_keepers
}
