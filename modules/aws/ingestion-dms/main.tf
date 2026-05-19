resource "aws_security_group" "dms" {
  name        = "${var.name_prefix}-dms-sg"
  description = "DMS replication instance access"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "dms_to_on_prem" {
  for_each = toset([for port in var.on_prem_ports : tostring(port)])

  type              = "egress"
  security_group_id = aws_security_group.dms.id
  protocol          = "tcp"
  from_port         = tonumber(each.value)
  to_port           = tonumber(each.value)
  cidr_blocks       = var.on_prem_cidrs
  description       = "Source database egress"
}

resource "aws_security_group_rule" "dms_to_redshift" {
  type                     = "egress"
  security_group_id        = aws_security_group.dms.id
  protocol                 = "tcp"
  from_port                = var.redshift.port
  to_port                  = var.redshift.port
  source_security_group_id = var.redshift.security_group_id
  description              = "Redshift target egress"
}

resource "aws_security_group_rule" "dms_to_rds" {
  type                     = "egress"
  security_group_id        = aws_security_group.dms.id
  protocol                 = "tcp"
  from_port                = var.rds.port
  to_port                  = var.rds.port
  source_security_group_id = var.rds.security_group_id
  description              = "RDS target egress"
}

resource "aws_security_group_rule" "redshift_from_dms" {
  type                     = "ingress"
  security_group_id        = var.redshift.security_group_id
  protocol                 = "tcp"
  from_port                = var.redshift.port
  to_port                  = var.redshift.port
  source_security_group_id = aws_security_group.dms.id
  description              = "DMS target writes"
}

resource "aws_security_group_rule" "rds_from_dms" {
  type                     = "ingress"
  security_group_id        = var.rds.security_group_id
  protocol                 = "tcp"
  from_port                = var.rds.port
  to_port                  = var.rds.port
  source_security_group_id = aws_security_group.dms.id
  description              = "DMS target writes"
}

resource "aws_dms_replication_subnet_group" "this" {
  replication_subnet_group_id          = "${var.name_prefix}-dms-subnets"
  replication_subnet_group_description = "Private subnets for DMS"
  subnet_ids                           = var.private_subnet_ids
}

resource "aws_iam_role" "secrets" {
  name                 = "${var.name_prefix}-dms-secrets-role"
  permissions_boundary = var.permissions_boundary_arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "dms.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "secrets" {
  name = "${var.name_prefix}-dms-secrets"
  role = aws_iam_role.secrets.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue",
      ]
      Resource = distinct(concat(
        [for endpoint in var.source_endpoints : endpoint.secret_arn],
        [var.redshift.secret_arn, var.rds.secret_arn],
      ))
    }]
  })
}

resource "aws_iam_role" "redshift_s3" {
  name                 = "${var.name_prefix}-dms-redshift-s3-role"
  permissions_boundary = var.permissions_boundary_arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "dms.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "redshift_s3" {
  name = "${var.name_prefix}-dms-redshift-s3"
  role = aws_iam_role.redshift_s3.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket",
      ]
      Resource = [
        var.redshift_staging_bucket_arn,
        "${var.redshift_staging_bucket_arn}/*",
      ]
    }]
  })
}

resource "aws_dms_replication_instance" "this" {
  replication_instance_id     = "${var.name_prefix}-dms"
  replication_instance_class  = var.replication_instance_class
  allocated_storage           = var.allocated_storage_gb
  multi_az                    = true
  publicly_accessible         = false
  replication_subnet_group_id = aws_dms_replication_subnet_group.this.id
  vpc_security_group_ids      = [aws_security_group.dms.id]
}

resource "aws_dms_endpoint" "source" {
  for_each = var.source_endpoints

  endpoint_id                    = "${var.name_prefix}-${each.key}-source"
  endpoint_type                  = "source"
  engine_name                    = each.value.engine_name
  database_name                  = each.value.database_name
  server_name                    = each.value.server_name
  port                           = each.value.port
  ssl_mode                       = each.value.ssl_mode
  secrets_manager_arn            = each.value.secret_arn
  secrets_manager_access_role_arn = aws_iam_role.secrets.arn
}

resource "aws_dms_endpoint" "redshift" {
  endpoint_id                     = "${var.name_prefix}-redshift-target"
  endpoint_type                   = "target"
  engine_name                     = "redshift"
  database_name                   = var.redshift.database_name
  server_name                     = var.redshift.server_name
  port                            = var.redshift.port
  ssl_mode                        = "require"
  secrets_manager_arn             = var.redshift.secret_arn
  secrets_manager_access_role_arn = aws_iam_role.secrets.arn

  redshift_settings {
    bucket_name             = var.redshift_staging_bucket_name
    bucket_folder           = "dms"
    service_access_role_arn = aws_iam_role.redshift_s3.arn
  }
}

resource "aws_dms_endpoint" "rds" {
  endpoint_id                     = "${var.name_prefix}-rds-target"
  endpoint_type                   = "target"
  engine_name                     = var.rds.engine_name
  database_name                   = var.rds.database_name
  server_name                     = var.rds.server_name
  port                            = var.rds.port
  ssl_mode                        = "require"
  secrets_manager_arn             = var.rds.secret_arn
  secrets_manager_access_role_arn = aws_iam_role.secrets.arn
}

resource "aws_dms_replication_task" "this" {
  for_each = var.tasks

  replication_task_id       = "${var.name_prefix}-${each.key}"
  migration_type            = each.value.migration_type
  replication_instance_arn  = aws_dms_replication_instance.this.replication_instance_arn
  source_endpoint_arn       = aws_dms_endpoint.source[each.value.source_key].endpoint_arn
  target_endpoint_arn       = each.value.target == "redshift" ? aws_dms_endpoint.redshift.endpoint_arn : aws_dms_endpoint.rds.endpoint_arn
  table_mappings            = each.value.table_mappings
  replication_task_settings = jsonencode(each.value.task_settings)
}
