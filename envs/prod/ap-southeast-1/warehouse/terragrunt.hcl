include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  repo_root = dirname(find_in_parent_folders("root.hcl"))
  env       = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "${local.repo_root}/modules/aws/warehouse"
}

dependency "network" {
  config_path = "../network"
}

dependency "storage_lake" {
  config_path = "../storage-lake"
}

inputs = {
  vpc_id                     = dependency.network.outputs.vpc_id
  private_subnet_ids         = dependency.network.outputs.private_subnet_ids
  workload_security_group_id = dependency.network.outputs.workload_security_group_id
  permissions_boundary_arn   = local.env.locals.permissions_boundary_arn
  spectrum_bucket_arns = [
    dependency.storage_lake.outputs.bucket_arns.raw,
    dependency.storage_lake.outputs.bucket_arns.curated_staging,
  ]
}
