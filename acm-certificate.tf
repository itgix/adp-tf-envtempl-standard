module "acm" {
  count  = var.acm_certificate_enable ? 1 : 0
  source = "git::git@github.com:itgix/tf-module-acm.git?ref=manage-multiple-acms"

  # To support previous setup with single domain;
  # Still need to define it in the config file for the argo and infra facts setup;
  r53_zone_id = var.dns_hosted_zone
  domain_name = "*.${var.dns_main_domain}"

  # Use this one for multiple domains;
  # If this one is used, the above one is not active for the terraform
  domain_names = var.dns_domain_names
}
