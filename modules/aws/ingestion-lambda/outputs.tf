output "function_names" {
  description = "Output from function names."
  value = {
    for key, fn in aws_lambda_function.this : key => fn.function_name
  }
}

output "function_arns" {
  description = "Output from function arns."
  value = {
    for key, fn in aws_lambda_function.this : key => fn.arn
  }
}

output "role_arn" {
  description = "Output from role arn."
  value = aws_iam_role.this.arn
}
