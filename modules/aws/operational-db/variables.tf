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

variable "engine" {
  description = "Input for engine."
  type    = string
  default = "postgres"
}

variable "engine_version" {
  description = "Input for engine version."
  type    = string
  default = "16.3"
}

variable "instance_class" {
  description = "Input for instance class."
  type    = string
  default = "db.m6i.large"
}

variable "allocated_storage_gb" {
  description = "Input for allocated storage gb."
  type    = number
  default = 100
}

variable "max_allocated_storage_gb" {
  description = "Input for max allocated storage gb."
  type    = number
  default = 1000
}

variable "database_name" {
  description = "Input for database name."
  type    = string
  default = "operational"
}

variable "admin_username" {
  description = "Input for admin username."
  type    = string
  default = "platform_admin"
}

variable "port" {
  description = "Input for port."
  type    = number
  default = 5432
}

variable "backup_retention_days" {
  description = "Input for backup retention days."
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
