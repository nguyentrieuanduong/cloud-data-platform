output "database_names" {
  description = "Output from database names."
  value = {
    raw         = aws_glue_catalog_database.raw.name
    operational = aws_glue_catalog_database.operational.name
    curated     = aws_glue_catalog_database.curated.name
  }
}

output "database_arns" {
  description = "Output from database arns."
  value = {
    raw         = aws_glue_catalog_database.raw.arn
    operational = aws_glue_catalog_database.operational.arn
    curated     = aws_glue_catalog_database.curated.arn
  }
}
