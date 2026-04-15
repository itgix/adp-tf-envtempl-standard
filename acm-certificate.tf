module "acm" {
  count  = var.acm_certificate_enable ? 1 : 0
  source = "git::git@github.com:itgix/tf-module-acm.git?ref=manage-multiple-acms"

  domain_names = var.dns_domain_names
}
