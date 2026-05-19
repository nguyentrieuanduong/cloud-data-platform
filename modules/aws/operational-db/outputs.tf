output "endpoint" {
  description = "Output from endpoint."
  value = aws_db_instance.this.address
}

output "identifier" {
  description = "Output from identifier."
  value = aws_db_instance.this.identifier
}

output "port" {
  description = "Output from port."
  value = aws_db_instance.this.port
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
