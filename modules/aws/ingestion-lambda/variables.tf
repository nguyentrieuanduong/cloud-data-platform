variable "name_prefix" {
  description = "Input for name prefix."
  type = string
}

variable "permissions_boundary_arn" {
  description = "Input for permissions boundary arn."
  type    = string
  default = null
}

variable "private_subnet_ids" {
  description = "Input for private subnet ids."
  type = list(string)
}

variable "workload_security_group_id" {
  description = "Input for workload security group id."
  type = string
}

variable "raw_bucket_name" {
  description = "Input for raw bucket name."
  type = string
}

variable "target_bucket_arns" {
  description = "Input for target bucket arns."
  type = list(string)
}

variable "secret_arns" {
  description = "Input for secret arns."
  type    = list(string)
  default = []
}

variable "proxy_host" {
  description = "Input for proxy host."
  type = string
}

variable "proxy_port" {
  description = "Input for proxy port."
  type = number
}

variable "log_retention_days" {
  description = "Input for log retention days."
  type    = number
  default = 30
}

variable "functions" {
  description = "Input for functions."
  type = map(object({
    s3_bucket         = string
    s3_key            = string
    s3_object_version = optional(string)
    handler           = string
    runtime           = optional(string, "python3.12")
    timeout           = optional(number, 300)
    memory_size       = optional(number, 512)
    environment       = optional(map(string), {})
  }))
}
