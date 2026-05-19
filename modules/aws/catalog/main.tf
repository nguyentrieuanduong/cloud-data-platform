resource "aws_glue_catalog_database" "raw" {
  name        = replace("${var.name_prefix}-raw", "-", "_")
  description = "Raw zone metadata for S3 landed data"
}

resource "aws_glue_catalog_database" "operational" {
  name        = replace("${var.name_prefix}-operational", "-", "_")
  description = "Operational cleaned data metadata"
}

resource "aws_glue_catalog_database" "curated" {
  name        = replace("${var.name_prefix}-curated", "-", "_")
  description = "Curated warehouse metadata and Spectrum external schemas"
}

resource "aws_glue_data_catalog_encryption_settings" "this" {
  data_catalog_encryption_settings {
    encryption_at_rest {
      catalog_encryption_mode = "SSE-KMS"
      sse_aws_kms_key_id      = "alias/aws/glue"
    }

    connection_password_encryption {
      return_connection_password_encrypted = true
      aws_kms_key_id                       = "alias/aws/glue"
    }
  }
}
