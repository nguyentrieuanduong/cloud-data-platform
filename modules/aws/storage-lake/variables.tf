variable "name_prefix" {
  description = "Input for name prefix."
  type = string
}

variable "force_destroy" {
  description = "Input for force destroy."
  type    = bool
  default = false
}

variable "log_retention_days" {
  description = "Input for log retention days."
  type    = number
  default = 365
}
