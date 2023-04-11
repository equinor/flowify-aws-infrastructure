################
# AWS Provider #
################
provider "aws" {
  region = var.region
}

locals {
  common_tags = {
    EnvClass  = var.env_class
    Owner     = "DevOps"
    Terraform = "true"
  }
}

#######################
# Creating S3 backend #
#######################

# This module creating S3 backend for environment
module "s3_backend" {
  source                     = "git@github.com:equinor/flowify-terraform-aws-s3-remote-state.git?ref=v.0.0.1"
  env_class                  = var.env_class
  create_dynamodb_lock_table = var.create_dynamodb_lock_table
  create_s3_bucket           = var.create_s3_bucket
  common_tags                = local.common_tags
}

