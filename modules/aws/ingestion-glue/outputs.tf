output "network_connection_names" {
  description = "Output from network connection names."
  value = values(aws_glue_connection.network)[*].name
}

output "job_names" {
  description = "Output from job names."
  value = {
    for key, job in aws_glue_job.this : key => job.name
  }
}

output "job_arns" {
  description = "Output from job arns."
  value = {
    for key, job in aws_glue_job.this : key => job.arn
  }
}

output "role_arn" {
  description = "Output from role arn."
  value = aws_iam_role.job.arn
}
