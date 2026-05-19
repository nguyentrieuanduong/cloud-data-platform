variable "name_prefix" {
  description = "Input for name prefix."
  type = string
}

variable "region" {
  description = "Input for region."
  type = string
}

variable "vpc_cidr" {
  description = "Input for vpc cidr."
  type = string
}

variable "public_subnet_cidrs" {
  description = "Input for public subnet cidrs."
  type = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == 1
    error_message = "The v0 network design requires exactly one public subnet."
  }
}

variable "private_subnet_cidrs" {
  description = "Input for private subnet cidrs."
  type = list(string)

  validation {
    condition     = length(var.private_subnet_cidrs) >= 2
    error_message = "MWAA requires at least two private subnets in different AZs."
  }
}

variable "on_prem_cidrs" {
  description = "Input for on prem cidrs."
  type = list(string)
}

variable "transit_gateway_id" {
  description = "Input for transit gateway id."
  type    = string
  default = null
}

variable "vgw_id" {
  description = "Input for vgw id."
  type    = string
  default = null
}

variable "proxy_port" {
  description = "Input for proxy port."
  type = number
}

variable "proxy_cidr_blocks" {
  description = "Input for proxy cidr blocks."
  type = list(string)
}

variable "repo_server_port" {
  description = "Input for repo server port."
  type = number
}

variable "repo_server_cidr_blocks" {
  description = "Input for repo server cidr blocks."
  type = list(string)
}

variable "workload_egress_ports" {
  description = "Input for workload egress ports."
  type = list(number)
}
