resource "aws_security_group" "glue" {
  name        = "${var.name_prefix}-glue-network-sg"
  description = "Glue NETWORK connection egress"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "glue_to_proxy" {
  type              = "egress"
  security_group_id = aws_security_group.glue.id
  protocol          = "tcp"
  from_port         = var.proxy_port
  to_port           = var.proxy_port
  cidr_blocks       = var.proxy_cidr_blocks
  description       = "HTTP proxy egress"
}

resource "aws_security_group_rule" "glue_to_on_prem" {
  for_each = toset([for port in var.on_prem_ports : tostring(port)])

  type              = "egress"
  security_group_id = aws_security_group.glue.id
  protocol          = "tcp"
  from_port         = tonumber(each.value)
  to_port           = tonumber(each.value)
  cidr_blocks       = var.on_prem_cidrs
  description       = "On-premises database egress"
}

resource "aws_glue_connection" "network" {
  for_each = {
    for index, subnet_id in var.private_subnet_ids : index => subnet_id
  }

  name            = "${var.name_prefix}-network-${tonumber(each.key) + 1}"
  connection_type = "NETWORK"

  physical_connection_requirements {
    availability_zone      = var.private_subnet_azs[tonumber(each.key)]
    security_group_id_list = [aws_security_group.glue.id]
    subnet_id              = each.value
  }
}

resource "aws_iam_role" "job" {
  name                 = "${var.name_prefix}-glue-job-role"
  permissions_boundary = var.permissions_boundary_arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "glue.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "service" {
  role       = aws_iam_role.job.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "data_access" {
  name = "${var.name_prefix}-glue-data"
  role = aws_iam_role.job.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
        ]
        Resource = concat(var.bucket_arns, [for arn in var.bucket_arns : "${arn}/*"])
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
        ]
        Resource = length(var.secret_arns) == 0 ? ["*"] : var.secret_arns
      },
    ]
  })
}

resource "aws_glue_job" "this" {
  for_each = var.jobs

  name     = "${var.name_prefix}-${each.key}"
  role_arn = aws_iam_role.job.arn

  glue_version      = each.value.glue_version
  worker_type       = each.value.worker_type
  number_of_workers = each.value.number_of_workers
  timeout           = each.value.timeout_minutes
  connections       = each.value.requires_on_prem ? values(aws_glue_connection.network)[*].name : []

  command {
    name            = "glueetl"
    python_version  = "3"
    script_location = each.value.script_location
  }

  default_arguments = merge(each.value.default_arguments, {
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-metrics"                   = "true"
    "--job-language"                     = "python"
    "--raw-bucket-name"                  = var.raw_bucket_name
  })
}
