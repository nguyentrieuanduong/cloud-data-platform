include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  repo_root = dirname(find_in_parent_folders("root.hcl"))
}

terraform {
  source = "${local.repo_root}/modules/aws/catalog"
}
