resource "random_password" "admin" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "admin" {
  name                    = "${var.name_prefix}-operational-db-admin"
  recovery_window_in_days = var.secret_recovery_window_days
}

resource "aws_secretsmanager_secret_version" "admin" {
  secret_id = aws_secretsmanager_secret.admin.id
  secret_string = jsonencode({
    username = var.admin_username
    password = random_password.admin.result
    engine   = var.engine
    host     = aws_db_instance.this.address
    port     = aws_db_instance.this.port
    dbname   = var.database_name
  })
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-operational-db-subnets"
  subnet_ids = var.private_subnet_ids
}

resource "aws_security_group" "this" {
  name        = "${var.name_prefix}-operational-db-sg"
  description = "Operational database private access"
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

resource "aws_db_instance" "this" {
  identifier = "${var.name_prefix}-operational-db"

  engine                = var.engine
  engine_version        = var.engine_version
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage_gb
  max_allocated_storage = var.max_allocated_storage_gb
  db_name               = var.database_name
  username              = var.admin_username
  password              = random_password.admin.result
  port                  = var.port

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  multi_az               = true
  publicly_accessible    = false
  storage_encrypted      = true
  kms_key_id             = "alias/aws/rds"

  backup_retention_period = var.backup_retention_days
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = !var.deletion_protection

  performance_insights_enabled = true
  apply_immediately            = false
}
