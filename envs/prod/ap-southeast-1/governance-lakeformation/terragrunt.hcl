include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  repo_root = dirname(find_in_parent_folders("root.hcl"))
  env       = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "${local.repo_root}/modules/aws/governance-lakeformation"
}

dependency "storage_lake" {
  config_path = "../storage-lake"
}

inputs = {
  admin_role_arns = [
    "arn:aws:iam::${local.env.locals.account_id}:role/vpbs-eda-${local.env.locals.environment}-lakeformation-admin",
  ]
  s3_location_arns = {
    raw             = dependency.storage_lake.outputs.bucket_arns.raw
    operational     = dependency.storage_lake.outputs.bucket_arns.raw
    curated_staging = dependency.storage_lake.outputs.bucket_arns.curated_staging
  }
}
