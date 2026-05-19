variable "account_id" {
  description = "Input for account id."
  type = string
}

variable "region" {
  description = "Input for region."
  type    = string
  default = "ap-southeast-1"
}

variable "org" {
  description = "Input for org."
  type    = string
  default = "vpbs"
}

variable "department" {
  description = "Input for department."
  type    = string
  default = "eda"
}

variable "project" {
  description = "Input for project."
  type    = string
  default = "cloud-data-platform"
}

variable "environment" {
  description = "Input for environment."
  type = string
}

variable "owner" {
  description = "Input for owner."
  type    = string
  default = "eda-platform"
}

variable "cost_center" {
  description = "Input for cost center."
  type    = string
  default = "eda"
}

variable "data_class" {
  description = "Input for data class."
  type = string
}

variable "name_prefix" {
  description = "Input for name prefix."
  type = string
}

variable "github_subjects" {
  description = "Input for github subjects."
  type = list(string)
}

variable "github_oidc_thumbprints" {
  description = "Input for github oidc thumbprints."
  type    = list(string)
  default = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

variable "permissions_boundary_arn" {
  description = "Input for permissions boundary arn."
  type    = string
  default = null
}
