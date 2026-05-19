include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  repo_root = dirname(find_in_parent_folders("root.hcl"))
  common    = read_terragrunt_config("${local.repo_root}/envs/_common/common.hcl")
  env       = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "${local.repo_root}/modules/aws/ingestion-glue"
}

dependency "network" {
  config_path = "../network"
}

dependency "storage_lake" {
  config_path = "../storage-lake"
}

inputs = {
  vpc_id                   = dependency.network.outputs.vpc_id
  private_subnet_ids       = dependency.network.outputs.private_subnet_ids
  private_subnet_azs       = dependency.network.outputs.private_subnet_azs
  proxy_port               = local.common.locals.proxy_port
  proxy_cidr_blocks        = local.common.locals.proxy_cidr_blocks
  on_prem_cidrs            = local.common.locals.on_prem_cidrs
  raw_bucket_name          = dependency.storage_lake.outputs.bucket_names.raw
  bucket_arns              = values(dependency.storage_lake.outputs.bucket_arns)
  permissions_boundary_arn = local.env.locals.permissions_boundary_arn

  jobs = {
    onprem_database_batch = {
      script_location  = "s3://${dependency.storage_lake.outputs.bucket_names.transform}/glue/onprem_database_batch.py"
      requires_on_prem = true
    }
  }
}
