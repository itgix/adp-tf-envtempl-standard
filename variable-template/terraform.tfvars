environment    = "dev"
aws_region     = "eu-central-1"
aws_account_id = "722377226063"
project_name   = "itgix"
aws_default_tags = {
  "platform:environment"    = "Development"
  "platform:customer"       = "Itgix"
}

# Networking
vpc_cidr            = "10.50.20.0/24"
allowed_cidr_blocks = ["10.50.0.0/16"]
