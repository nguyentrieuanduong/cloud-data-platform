output "vpc_id" {
  description = "Output from vpc id."
  value = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "Output from vpc cidr."
  value = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "Output from public subnet ids."
  value = values(aws_subnet.public)[*].id
}

output "private_subnet_ids" {
  description = "Output from private subnet ids."
  value = values(aws_subnet.private)[*].id
}

output "private_subnet_azs" {
  description = "Output from private subnet azs."
  value = values(aws_subnet.private)[*].availability_zone
}

output "workload_security_group_id" {
  description = "Output from workload security group id."
  value = aws_security_group.workloads.id
}

output "endpoint_security_group_id" {
  description = "Output from endpoint security group id."
  value = aws_security_group.vpc_endpoints.id
}
