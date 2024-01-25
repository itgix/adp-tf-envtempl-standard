#########################################################################
##                     General Configuration Variables                 ##
#########################################################################

variable "aws_account_id" {
  type        = string
  description = "AWS account to deploy resources"
}

variable "aws_region" {
  type        = string
  description = "AWS region to deploy to"
}

variable "aws_default_tags" {
  type        = map(string)
  description = "Default tags to use in AWS resources"

}

variable "environment" {
  type        = string
  description = "Environment in which the infrastructure is going to be deployed"
}

variable "project_name" {
  type        = string
  description = "Name of the project / client / product to be used in naming convention"
}


#########################################################################
##                   Networking Variables                              ##
#########################################################################

variable "vpc_cidr" {
  type        = string
  description = "CIDR of VPC to be used by Resale common resources"
}

variable "allowed_cidr_blocks" {
  type        = list(any)
  description = "List of CIDRs allowed by the security group"
}

