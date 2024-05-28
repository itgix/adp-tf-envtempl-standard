module "acm" {
  count  = var.acm_certificate_enable ? 1 : 0
  source = "git::ssh://git@gitlab.itgix.com/rnd/app-platform/iac-modules/tf-module-acm.git?ref=main"
  # Configured for wildcard certificate
  domain_name = "*.${var.dns_main_domain}"
  r53_zone_id = var.dns_hosted_zone
}
