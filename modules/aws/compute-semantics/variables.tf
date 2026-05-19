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

variable "proxy_host" {
  description = "Input for proxy host."
  type = string
}

variable "proxy_port" {
  description = "Input for proxy port."
  type = number
}

variable "repo_server_host" {
  description = "Input for repo server host."
  type = string
}

variable "repo_server_port" {
  description = "Input for repo server port."
  type = number
}

variable "secret_arns" {
  description = "Input for secret arns."
  type    = list(string)
  default = []
}

variable "ami_id" {
  description = "Input for ami id."
  type    = string
  default = null
}

variable "instance_type" {
  description = "Input for instance type."
  type    = string
  default = "t3.medium"
}

variable "min_size" {
  description = "Input for min size."
  type    = number
  default = 1
}

variable "max_size" {
  description = "Input for max size."
  type    = number
  default = 2
}

variable "desired_capacity" {
  description = "Input for desired capacity."
  type    = number
  default = 1
}
