variable "name_prefix" {
  description = "Input for name prefix."
  type = string
}

variable "alert_email_endpoints" {
  description = "Input for alert email endpoints."
  type    = list(string)
  default = []
}

variable "cpu_alarm_threshold" {
  description = "Input for cpu alarm threshold."
  type    = number
  default = 80
}

variable "redshift_cluster_identifier" {
  description = "Input for redshift cluster identifier."
  type    = string
  default = null
}

variable "rds_identifier" {
  description = "Input for rds identifier."
  type    = string
  default = null
}

variable "dms_replication_instance_identifier" {
  description = "Input for dms replication instance identifier."
  type    = string
  default = null
}
