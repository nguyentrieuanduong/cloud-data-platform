output "state_bucket_name" {
  description = "Output from state bucket name."
  value = aws_s3_bucket.state.id
}

output "github_deploy_role_arn" {
  description = "Output from github deploy role arn."
  value = aws_iam_role.github_deploy.arn
}
