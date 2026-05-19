output "cluster_identifier" {
  description = "Output from cluster identifier."
  value = aws_redshift_cluster.this.cluster_identifier
}

output "endpoint" {
  description = "Output from endpoint."
  value = aws_redshift_cluster.this.endpoint
}

output "port" {
  description = "Output from port."
  value = aws_redshift_cluster.this.port
}

output "security_group_id" {
  description = "Output from security group id."
  value = aws_security_group.this.id
}

output "admin_secret_arn" {
  description = "Output from admin secret arn."
  value     = aws_secretsmanager_secret.admin.arn
  sensitive = true
}

output "spectrum_role_arn" {
  description = "Output from spectrum role arn."
  value = aws_iam_role.spectrum.arn
}
