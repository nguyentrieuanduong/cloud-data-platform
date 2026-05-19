include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  repo_root = dirname(find_in_parent_folders("root.hcl"))
  env       = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "${local.repo_root}/modules/aws/orchestration-mwaa"
}

dependency "network" {
  config_path = "../network"
}

dependency "storage_lake" {
  config_path = "../storage-lake"
}

dependency "ingestion_lambda" {
  config_path = "../ingestion-lambda"
}

dependency "ingestion_glue" {
  config_path = "../ingestion-glue"
}

dependency "ingestion_dms" {
  config_path = "../ingestion-dms"
}

inputs = {
  private_subnet_ids         = dependency.network.outputs.private_subnet_ids
  workload_security_group_id = dependency.network.outputs.workload_security_group_id
  dag_bucket_arn             = dependency.storage_lake.outputs.bucket_arns.mwaa_dags
  log_bucket_arn             = dependency.storage_lake.outputs.bucket_arns.logs
  lambda_function_arns       = dependency.ingestion_lambda.outputs.function_arns
  glue_job_arns              = dependency.ingestion_glue.outputs.job_arns
  dms_task_arns              = dependency.ingestion_dms.outputs.task_arns
  permissions_boundary_arn   = local.env.locals.permissions_boundary_arn
}
