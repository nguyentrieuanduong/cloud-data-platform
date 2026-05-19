output "environment_name" {
  description = "Output from environment name."
  value = aws_mwaa_environment.this.name
}

output "webserver_url" {
  description = "Output from webserver url."
  value = aws_mwaa_environment.this.webserver_url
}

output "execution_role_arn" {
  description = "Output from execution role arn."
  value = aws_iam_role.execution.arn
}
