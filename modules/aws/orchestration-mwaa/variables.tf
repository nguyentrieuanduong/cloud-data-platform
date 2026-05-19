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

variable "dag_bucket_arn" {
  description = "Input for dag bucket arn."
  type = string
}

variable "log_bucket_arn" {
  description = "Input for log bucket arn."
  type = string
}

variable "dag_s3_path" {
  description = "Input for dag s3 path."
  type    = string
  default = "dags"
}

variable "requirements_s3_path" {
  description = "Input for requirements s3 path."
  type    = string
  default = null
}

variable "airflow_version" {
  description = "Input for airflow version."
  type    = string
  default = "2.10.3"
}

variable "environment_class" {
  description = "Input for environment class."
  type    = string
  default = "mw1.small"
}

variable "min_workers" {
  description = "Input for min workers."
  type    = number
  default = 1
}

variable "max_workers" {
  description = "Input for max workers."
  type    = number
  default = 4
}

variable "schedulers" {
  description = "Input for schedulers."
  type    = number
  default = 2
}

variable "lambda_function_arns" {
  description = "Input for lambda function arns."
  type    = map(string)
  default = {}
}

variable "glue_job_arns" {
  description = "Input for glue job arns."
  type    = map(string)
  default = {}
}

variable "dms_task_arns" {
  description = "Input for dms task arns."
  type    = map(string)
  default = {}
}

variable "secret_arns" {
  description = "Input for secret arns."
  type    = list(string)
  default = []
}
