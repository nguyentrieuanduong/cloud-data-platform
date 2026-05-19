locals {
  buckets = {
    raw             = "raw-bucket"
    transform       = "transform-scripts"
    logs            = "job-logs"
    athena_results  = "athena-results"
    curated_staging = "curated-staging"
    lambda_artifact = "lambda-artifacts"
    mwaa_dags       = "mwaa-dags"
  }
}

resource "aws_s3_bucket" "this" {
  for_each = local.buckets

  bucket        = "${var.name_prefix}-${each.value}"
  force_destroy = var.force_destroy

  tags = {
    Name = "${var.name_prefix}-${each.value}"
    Zone = each.key
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = aws_s3_bucket.this

  bucket                  = each.value.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = "alias/aws/s3"
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.this["logs"].id

  rule {
    id     = "expire-old-job-logs"
    status = "Enabled"

    filter {}

    expiration {
      days = var.log_retention_days
    }
  }
}
