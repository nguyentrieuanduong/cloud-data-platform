output "replication_instance_arn" {
  description = "Output from replication instance arn."
  value = aws_dms_replication_instance.this.replication_instance_arn
}

output "replication_instance_id" {
  description = "Output from replication instance id."
  value = aws_dms_replication_instance.this.replication_instance_id
}

output "task_arns" {
  description = "Output from task arns."
  value = {
    for key, task in aws_dms_replication_task.this : key => task.replication_task_arn
  }
}

output "security_group_id" {
  description = "Output from security group id."
  value = aws_security_group.dms.id
}
