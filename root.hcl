locals {
  repo_root = dirname(find_in_parent_folders("root.hcl"))
  common    = read_terragrunt_config("${local.repo_root}/envs/_common/common.hcl")
  env    = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  org          = local.common.locals.org
  department   = local.common.locals.department
  project      = local.common.locals.project
  region       = local.common.locals.region
  region_short = local.common.locals.region_short
  environment  = local.env.locals.environment
  account_id   = local.env.locals.account_id

  name_prefix = "${local.org}-${local.department}-${local.environment}-${local.region_short}"
  state_bucket = "${local.name_prefix}-tfstate"
}

remote_state {
  backend = "s3"
  config = {
    bucket       = local.state_bucket
    key          = "${path_relative_to_include()}/terraform.tfstate"
    region       = local.region
    encrypt      = true
    use_lockfile = true
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = "${local.region}"

  allowed_account_ids = ["${local.account_id}"]

  default_tags {
    tags = {
      Org         = "${local.org}"
      Department  = "${local.department}"
      Project     = "${local.project}"
      Environment = "${local.environment}"
      Owner       = "${local.common.locals.owner}"
      CostCenter  = "${local.common.locals.cost_center}"
      DataClass   = "${local.env.locals.data_class}"
      ManagedBy   = "terraform"
    }
  }
}
EOF
}

inputs = {
  name_prefix = local.name_prefix
}
