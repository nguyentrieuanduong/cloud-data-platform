include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  repo_root = dirname(find_in_parent_folders("root.hcl"))
}

terraform {
  source = "${local.repo_root}/modules/aws/observability"
}

dependency "warehouse" {
  config_path = "../warehouse"
}

dependency "operational_db" {
  config_path = "../operational-db"
}

dependency "ingestion_dms" {
  config_path = "../ingestion-dms"
}

inputs = {
  redshift_cluster_identifier        = dependency.warehouse.outputs.cluster_identifier
  rds_identifier                     = dependency.operational_db.outputs.identifier
  dms_replication_instance_identifier = dependency.ingestion_dms.outputs.replication_instance_id
}
