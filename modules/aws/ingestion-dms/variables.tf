variable "name_prefix" {
  description = "Input for name prefix."
  type = string
}

variable "permissions_boundary_arn" {
  description = "Input for permissions boundary arn."
  type    = string
  default = null
}

variable "vpc_id" {
  description = "Input for vpc id."
  type = string
}

variable "private_subnet_ids" {
  description = "Input for private subnet ids."
  type = list(string)
}

variable "on_prem_cidrs" {
  description = "Input for on prem cidrs."
  type = list(string)
}

variable "on_prem_ports" {
  description = "Input for on prem ports."
  type    = list(number)
  default = [5432, 3306, 1433, 1521]
}

variable "replication_instance_class" {
  description = "Input for replication instance class."
  type    = string
  default = "dms.t3.medium"
}

variable "allocated_storage_gb" {
  description = "Input for allocated storage gb."
  type    = number
  default = 100
}

variable "redshift_staging_bucket_name" {
  description = "Input for redshift staging bucket name."
  type = string
}

variable "redshift_staging_bucket_arn" {
  description = "Input for redshift staging bucket arn."
  type = string
}

variable "source_endpoints" {
  description = "Input for source endpoints."
  type = map(object({
    engine_name   = string
    server_name   = string
    port          = number
    database_name = string
    secret_arn    = string
    ssl_mode      = optional(string, "require")
  }))
}

variable "redshift" {
  description = "Input for redshift."
  type = object({
    server_name       = string
    port              = number
    database_name     = string
    secret_arn        = string
    security_group_id = string
  })
}

variable "rds" {
  description = "Input for rds."
  type = object({
    engine_name        = string
    server_name        = string
    port               = number
    database_name      = string
    secret_arn         = string
    security_group_id  = string
  })
}

variable "tasks" {
  description = "Input for tasks."
  type = map(object({
    source_key     = string
    target         = string
    migration_type = optional(string, "cdc")
    table_mappings = string
    task_settings  = optional(any, {})
  }))

  validation {
    condition = alltrue([
      for task in values(var.tasks) : contains(["redshift", "rds"], task.target)
    ])
    error_message = "Each DMS task target must be redshift or rds."
  }
}
