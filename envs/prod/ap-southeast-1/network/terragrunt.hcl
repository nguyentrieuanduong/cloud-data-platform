include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  repo_root = dirname(find_in_parent_folders("root.hcl"))
  common    = read_terragrunt_config("${local.repo_root}/envs/_common/common.hcl")
  env       = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "${local.repo_root}/modules/aws/network"
}

inputs = {
  vpc_cidr                  = local.env.locals.vpc_cidr
  public_subnet_cidrs       = local.env.locals.public_subnet_cidrs
  private_subnet_cidrs      = local.env.locals.private_subnet_cidrs
  transit_gateway_id        = local.env.locals.transit_gateway_id
  vgw_id                    = local.env.locals.vgw_id
  region                    = local.common.locals.region
  on_prem_cidrs             = local.common.locals.on_prem_cidrs
  proxy_port                = local.common.locals.proxy_port
  proxy_cidr_blocks         = local.common.locals.proxy_cidr_blocks
  repo_server_port          = local.common.locals.repo_server_port
  repo_server_cidr_blocks   = local.common.locals.repo_server_cidr_blocks
  workload_egress_ports     = local.common.locals.workload_egress_ports
}
