output "asg_name" {
  description = "Output from asg name."
  value = aws_autoscaling_group.this.name
}

output "instance_role_arn" {
  description = "Output from instance role arn."
  value = aws_iam_role.instance.arn
}
