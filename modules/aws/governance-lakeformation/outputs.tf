output "registered_locations" {
  description = "Output from registered locations."
  value = keys(aws_lakeformation_resource.s3)
}

output "lf_tags" {
  description = "Output from lf tags."
  value = {
    data_class = aws_lakeformation_lf_tag.data_class.key
    zone       = aws_lakeformation_lf_tag.zone.key
  }
}
