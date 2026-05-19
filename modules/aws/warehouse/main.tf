data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "random_password" "admin" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "admin" {
  name                    = "${var.name_prefix}-redshift-admin"
  recovery_window_in_days = var.secret_recovery_window_days
}

resource "aws_secretsmanager_secret_version" "admin" {
  secret_id = aws_secretsmanager_secret.admin.id
  secret_string = jsonencode({
    username = var.admin_username
    password = random_password.admin.result
    engine   = "redshift"
    host     = aws_redshift_cluster.this.endpoint
    port     = aws_redshift_cluster.this.port
    dbname   = var.database_name
  })
}

resource "aws_redshift_subnet_group" "this" {
  name       = "${var.name_prefix}-redshift-subnets"
  subnet_ids = var.private_subnet_ids
}

resource "aws_security_group" "this" {
  name        = "${var.name_prefix}-redshift-sg"
  description = "Redshift private access"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "from_workloads" {
  type                     = "ingress"
  security_group_id        = aws_security_group.this.id
  protocol                 = "tcp"
  from_port                = var.port
  to_port                  = var.port
  source_security_group_id = var.workload_security_group_id
  description              = "Private workload access"
}

resource "aws_iam_role" "spectrum" {
  name                 = "${var.name_prefix}-redshift-spectrum-role"
  permissions_boundary = var.permissions_boundary_arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "redshift.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "spectrum" {
  name = "${var.name_prefix}-redshift-spectrum"
  role = aws_iam_role.spectrum.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:GetTable",
          "glue:GetTables",
          "glue:GetPartition",
          "glue:GetPartitions",
        ]
        Resource = [
          "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:catalog",
          "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:database/*",
          "arn:aws:glue:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/*/*",
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
        ]
        Resource = concat(
          var.spectrum_bucket_arns,
          [for arn in var.spectrum_bucket_arns : "${arn}/*"],
        )
      },
    ]
  })
}

resource "aws_redshift_cluster" "this" {
  cluster_identifier = "${var.name_prefix}-redshift-cluster"
  database_name      = var.database_name
  master_username    = var.admin_username
  master_password    = random_password.admin.result

  node_type       = var.node_type
  cluster_type    = "multi-node"
  number_of_nodes = var.number_of_nodes
  multi_az        = true

  port                                = var.port
  cluster_subnet_group_name           = aws_redshift_subnet_group.this.name
  vpc_security_group_ids              = [aws_security_group.this.id]
  publicly_accessible                 = false
  encrypted                           = true
  kms_key_id                          = "alias/aws/redshift"
  enhanced_vpc_routing                = true
  iam_roles                           = [aws_iam_role.spectrum.arn]
  automated_snapshot_retention_period = var.snapshot_retention_days

  allow_version_upgrade      = true
  deletion_protection        = var.deletion_protection
  skip_final_snapshot        = false
  final_snapshot_identifier  = "${var.name_prefix}-redshift-final"
}
