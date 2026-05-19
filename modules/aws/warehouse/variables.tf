variable "name_prefix" {
  description = "Input for name prefix."
  type = string
}

variable "vpc_id" {
  description = "Input for vpc id."
  type = string
}

variable "private_subnet_ids" {
  description = "Input for private subnet ids."
  type = list(string)
}

variable "workload_security_group_id" {
  description = "Input for workload security group id."
  type = string
}

variable "permissions_boundary_arn" {
  description = "Input for permissions boundary arn."
  type    = string
  default = null
}

variable "spectrum_bucket_arns" {
  description = "Input for spectrum bucket arns."
  type = list(string)
}

variable "database_name" {
  description = "Input for database name."
  type    = string
  default = "curated"
}

variable "admin_username" {
  description = "Input for admin username."
  type    = string
  default = "platform_admin"
}

variable "node_type" {
  description = "Input for node type."
  type    = string
  default = "ra3.xlplus"
}

variable "number_of_nodes" {
  description = "Input for number of nodes."
  type    = number
  default = 2
}

variable "port" {
  description = "Input for port."
  type    = number
  default = 5439
}

variable "snapshot_retention_days" {
  description = "Input for snapshot retention days."
  type    = number
  default = 7
}

variable "deletion_protection" {
  description = "Input for deletion protection."
  type    = bool
  default = true
}

variable "secret_recovery_window_days" {
  description = "Input for secret recovery window days."
  type    = number
  default = 30
}
