module "wafv2_application" {
  source                      = "git::git@gitlab.itgix.com:rnd/itgix-aws-landing-zones.git?ref=main"
  waf_enabled                 = var.application_waf_enabled
  project                     = var.project_name
  env                         = var.environment
  aws_region                  = var.region
  pid                         = var.pid
  web_acl_scope               = "REGIONAL"
  waf_attachment_type         = "application" # appended to WebACL and Log Group name
  web_acl_cloudwatch_enabled  = var.waf_webacl_cloudwatch_enabled
  sampled_requests_enabled    = var.waf_sampled_requests_enabled
  aws_waf_logging_enabled     = var.application_waf_enabled ? var.waf_logging_enabled : false
  waf_log_retention_days      = var.waf_log_retention_days
  country_codes_match         = var.waf_country_codes_match     # list of countries to be blocked by WAF
  aws_managed_waf_rule_groups = var.aws_managed_waf_rule_groups # list of AWS managed security rules to be enabled
}

module "wafv2_cloudfront" {
  source      = "../modules/wafv2"
  waf_enabled = var.cloudfront_waf_enabled

  providers = {
    aws = aws.virginia
  }

  project                     = var.project_name
  env                         = var.environment
  aws_region                  = var.region
  pid                         = var.pid
  web_acl_scope               = "CLOUDFRONT"
  waf_attachment_type         = "cloudfront" # appended to WebACL and Log Group name
  web_acl_cloudwatch_enabled  = var.waf_webacl_cloudwatch_enabled
  sampled_requests_enabled    = var.waf_sampled_requests_enabled
  aws_waf_logging_enabled     = var.cloudfront_waf_enabled ? var.waf_logging_enabled : false
  waf_log_retention_days      = var.waf_log_retention_days
  country_codes_match         = var.waf_country_codes_match     # list of countries to be blocked by WAF
  aws_managed_waf_rule_groups = var.aws_managed_waf_rule_groups # list of AWS managed security rules to be enabled
}
