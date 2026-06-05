module "acm" {
  count  = var.acm_certificate_enable ? 1 : 0
  source = "git::git@github.com:itgix/tf-module-acm.git?ref=v1.0.3"

  # To support previous setup with single domain;
  # Still need to define it in the config file for the argo and infra facts setup;
  r53_zone_id = var.dns_hosted_zone
  domain_name = "*.${var.dns_main_domain}"

  # Use this one if you want to add more domains;
  domain_names = var.dns_domain_names

  # If you want to skip the creation of the route53 validation records, set this to false;
  create_route53_validation_records = var.acm_create_route53_validation_records
}
