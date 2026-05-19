include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  repo_root = dirname(find_in_parent_folders("root.hcl"))
  common    = read_terragrunt_config("${local.repo_root}/envs/_common/common.hcl")
  env       = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "${local.repo_root}/modules/aws/compute-semantics"
}

dependency "network" {
  config_path = "../network"
}

dependency "warehouse" {
  config_path = "../warehouse"
}

dependency "operational_db" {
  config_path = "../operational-db"
}

inputs = {
  private_subnet_ids         = dependency.network.outputs.private_subnet_ids
  workload_security_group_id = dependency.network.outputs.workload_security_group_id
  permissions_boundary_arn   = local.env.locals.permissions_boundary_arn
  proxy_host                 = local.common.locals.proxy_host
  proxy_port                 = local.common.locals.proxy_port
  repo_server_host           = local.common.locals.repo_server_host
  repo_server_port           = local.common.locals.repo_server_port
  secret_arns = [
    dependency.warehouse.outputs.admin_secret_arn,
    dependency.operational_db.outputs.admin_secret_arn,
  ]
}
