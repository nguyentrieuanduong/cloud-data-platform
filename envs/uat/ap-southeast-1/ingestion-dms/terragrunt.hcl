include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  repo_root = dirname(find_in_parent_folders("root.hcl"))
  common    = read_terragrunt_config("${local.repo_root}/envs/_common/common.hcl")
  env       = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "${local.repo_root}/modules/aws/ingestion-dms"
}

dependency "network" {
  config_path = "../network"
}

dependency "storage_lake" {
  config_path = "../storage-lake"
}

dependency "warehouse" {
  config_path = "../warehouse"
}

dependency "operational_db" {
  config_path = "../operational-db"
}

inputs = {
  vpc_id                       = dependency.network.outputs.vpc_id
  private_subnet_ids           = dependency.network.outputs.private_subnet_ids
  on_prem_cidrs                = local.common.locals.on_prem_cidrs
  redshift_staging_bucket_name = dependency.storage_lake.outputs.bucket_names.curated_staging
  redshift_staging_bucket_arn  = dependency.storage_lake.outputs.bucket_arns.curated_staging
  permissions_boundary_arn     = local.env.locals.permissions_boundary_arn

  source_endpoints = {}

  redshift = {
    server_name       = split(":", dependency.warehouse.outputs.endpoint)[0]
    port              = dependency.warehouse.outputs.port
    database_name     = "curated"
    secret_arn        = dependency.warehouse.outputs.admin_secret_arn
    security_group_id = dependency.warehouse.outputs.security_group_id
  }

  rds = {
    engine_name        = "postgres"
    server_name        = dependency.operational_db.outputs.endpoint
    port               = dependency.operational_db.outputs.port
    database_name      = "operational"
    secret_arn         = dependency.operational_db.outputs.admin_secret_arn
    security_group_id  = dependency.operational_db.outputs.security_group_id
  }

  tasks = {}
}
