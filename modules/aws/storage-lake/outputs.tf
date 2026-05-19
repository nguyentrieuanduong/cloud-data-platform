output "bucket_names" {
  description = "Output from bucket names."
  value = {
    for key, bucket in aws_s3_bucket.this : key => bucket.id
  }
}

output "bucket_arns" {
  description = "Output from bucket arns."
  value = {
    for key, bucket in aws_s3_bucket.this : key => bucket.arn
  }
}
