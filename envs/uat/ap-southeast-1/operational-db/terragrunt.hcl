include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  repo_root = dirname(find_in_parent_folders("root.hcl"))
  env       = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "${local.repo_root}/modules/aws/operational-db"
}

dependency "network" {
  config_path = "../network"
}

inputs = {
  vpc_id                     = dependency.network.outputs.vpc_id
  private_subnet_ids         = dependency.network.outputs.private_subnet_ids
  workload_security_group_id = dependency.network.outputs.workload_security_group_id
  deletion_protection        = local.env.locals.environment == "prod"
}
