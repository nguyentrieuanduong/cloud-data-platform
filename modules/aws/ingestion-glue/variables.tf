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

variable "private_subnet_azs" {
  description = "Input for private subnet azs."
  type = list(string)
}

variable "proxy_port" {
  description = "Input for proxy port."
  type = number
}

variable "proxy_cidr_blocks" {
  description = "Input for proxy cidr blocks."
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

variable "raw_bucket_name" {
  description = "Input for raw bucket name."
  type = string
}

variable "bucket_arns" {
  description = "Input for bucket arns."
  type = list(string)
}

variable "secret_arns" {
  description = "Input for secret arns."
  type    = list(string)
  default = []
}

variable "jobs" {
  description = "Input for jobs."
  type = map(object({
    script_location   = string
    requires_on_prem  = optional(bool, true)
    glue_version      = optional(string, "5.0")
    worker_type       = optional(string, "G.1X")
    number_of_workers = optional(number, 2)
    timeout_minutes   = optional(number, 60)
    default_arguments = optional(map(string), {})
  }))
}
