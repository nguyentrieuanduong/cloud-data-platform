include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  repo_root = dirname(find_in_parent_folders("root.hcl"))
  common    = read_terragrunt_config("${local.repo_root}/envs/_common/common.hcl")
  env       = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "${local.repo_root}/modules/aws/ingestion-lambda"
}

dependency "network" {
  config_path = "../network"
}

dependency "storage_lake" {
  config_path = "../storage-lake"
}

inputs = {
  private_subnet_ids         = dependency.network.outputs.private_subnet_ids
  workload_security_group_id = dependency.network.outputs.workload_security_group_id
  raw_bucket_name            = dependency.storage_lake.outputs.bucket_names.raw
  target_bucket_arns         = [dependency.storage_lake.outputs.bucket_arns.raw]
  permissions_boundary_arn   = local.env.locals.permissions_boundary_arn
  proxy_host                 = local.common.locals.proxy_host
  proxy_port                 = local.common.locals.proxy_port

  functions = {
    kafka = {
      s3_bucket = dependency.storage_lake.outputs.bucket_names.lambda_artifact
      s3_key    = "ingestion/kafka/latest.zip"
      handler   = "handler.lambda_handler"
    }
    external_api = {
      s3_bucket = dependency.storage_lake.outputs.bucket_names.lambda_artifact
      s3_key    = "ingestion/external-api/latest.zip"
      handler   = "handler.lambda_handler"
    }
    sharepoint = {
      s3_bucket = dependency.storage_lake.outputs.bucket_names.lambda_artifact
      s3_key    = "ingestion/sharepoint/latest.zip"
      handler   = "handler.lambda_handler"
    }
  }
}
