resource "aws_lakeformation_data_lake_settings" "this" {
  admins = var.admin_role_arns
}

resource "aws_lakeformation_resource" "s3" {
  for_each = var.s3_location_arns

  arn                     = each.value
  use_service_linked_role = true
}

resource "aws_lakeformation_lf_tag" "data_class" {
  key    = "DataClass"
  values = var.data_class_values
}

resource "aws_lakeformation_lf_tag" "zone" {
  key    = "Zone"
  values = ["raw", "operational", "curated", "insight"]
}

resource "aws_lakeformation_permissions" "admin_data_location" {
  for_each = {
    for pair in setproduct(toset(var.admin_role_arns), keys(var.s3_location_arns)) :
    "${pair[0]}:${pair[1]}" => {
      principal = pair[0]
      location  = aws_lakeformation_resource.s3[pair[1]].arn
    }
  }

  principal   = each.value.principal
  permissions = ["DATA_LOCATION_ACCESS"]

  data_location {
    arn = each.value.location
  }

  depends_on = [aws_lakeformation_data_lake_settings.this]
}
