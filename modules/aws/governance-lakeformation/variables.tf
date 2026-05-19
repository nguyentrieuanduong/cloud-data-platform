variable "name_prefix" {
  description = "Input for name prefix."
  type = string
}

variable "admin_role_arns" {
  description = "Input for admin role arns."
  type = list(string)
}

variable "s3_location_arns" {
  description = "Input for s3 location arns."
  type = map(string)
}

variable "data_class_values" {
  description = "Input for data class values."
  type    = list(string)
  default = ["internal", "confidential", "restricted"]
}
