data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  private_azs = slice(data.aws_availability_zones.available.names, 0, length(var.private_subnet_cidrs))
  public_azs  = slice(data.aws_availability_zones.available.names, 0, length(var.public_subnet_cidrs))

  endpoint_services = toset([
    "sts",
    "kms",
    "secretsmanager",
    "ecr.api",
    "ecr.dkr",
    "logs",
    "ssm",
    "ssmmessages",
    "ec2messages",
    "glue",
    "redshift-data",
    "airflow.api",
    "airflow.env",
    "dms",
  ])

  gateway_endpoint_services = toset([
    "s3",
    "dynamodb",
  ])
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

resource "aws_subnet" "public" {
  for_each = {
    for index, cidr in var.public_subnet_cidrs : index => {
      cidr = cidr
      az   = local.public_azs[index]
    }
  }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}-public-${tonumber(each.key) + 1}"
    Tier = "public"
  }
}

resource "aws_subnet" "private" {
  for_each = {
    for index, cidr in var.private_subnet_cidrs : index => {
      cidr = cidr
      az   = local.private_azs[index]
    }
  }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${var.name_prefix}-private-${tonumber(each.key) + 1}"
    Tier = "private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-public-rt"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  route_table_id = aws_route_table.public.id
  subnet_id      = each.value.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  route_table_id = aws_route_table.private.id
  subnet_id      = each.value.id
}

resource "aws_route" "on_prem_tgw" {
  for_each = toset(var.transit_gateway_id == null ? [] : var.on_prem_cidrs)

  route_table_id         = aws_route_table.private.id
  destination_cidr_block = each.key
  transit_gateway_id     = var.transit_gateway_id
}

resource "aws_route" "on_prem_vgw" {
  for_each = toset(var.vgw_id == null ? [] : var.on_prem_cidrs)

  route_table_id         = aws_route_table.private.id
  destination_cidr_block = each.key
  gateway_id             = var.vgw_id
}

resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.name_prefix}-vpce-sg"
  description = "Allow private workloads to reach interface VPC endpoints"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Endpoint responses"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name_prefix}-vpce-sg"
  }
}

resource "aws_security_group" "workloads" {
  name        = "${var.name_prefix}-workload-sg"
  description = "Default private workload egress guardrails"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "${var.name_prefix}-workload-sg"
  }
}

resource "aws_security_group_rule" "workload_to_proxy" {
  type              = "egress"
  security_group_id = aws_security_group.workloads.id
  protocol          = "tcp"
  from_port         = var.proxy_port
  to_port           = var.proxy_port
  cidr_blocks       = var.proxy_cidr_blocks
  description       = "HTTP proxy egress"
}

resource "aws_security_group_rule" "workload_to_repo_server" {
  type              = "egress"
  security_group_id = aws_security_group.workloads.id
  protocol          = "tcp"
  from_port         = var.repo_server_port
  to_port           = var.repo_server_port
  cidr_blocks       = var.repo_server_cidr_blocks
  description       = "Internal package mirror egress"
}

resource "aws_security_group_rule" "workload_to_on_prem" {
  for_each = toset([for port in var.workload_egress_ports : tostring(port)])

  type              = "egress"
  security_group_id = aws_security_group.workloads.id
  protocol          = "tcp"
  from_port         = tonumber(each.value)
  to_port           = tonumber(each.value)
  cidr_blocks       = var.on_prem_cidrs
  description       = "Declared on-premises service egress"
}

resource "aws_security_group_rule" "workload_to_endpoints" {
  type                     = "egress"
  security_group_id        = aws_security_group.workloads.id
  protocol                 = "tcp"
  from_port                = 443
  to_port                  = 443
  source_security_group_id = aws_security_group.vpc_endpoints.id
  description              = "AWS service VPC endpoints"
}

resource "aws_vpc_endpoint" "interface" {
  for_each = local.endpoint_services

  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.region}.${each.key}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = values(aws_subnet.private)[*].id
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]

  tags = {
    Name = "${var.name_prefix}-${replace(each.key, ".", "-")}-vpce"
  }
}

resource "aws_vpc_endpoint" "gateway" {
  for_each = local.gateway_endpoint_services

  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.region}.${each.key}"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = {
    Name = "${var.name_prefix}-${each.key}-vpce"
  }
}
