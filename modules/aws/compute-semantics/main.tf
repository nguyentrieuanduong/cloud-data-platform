data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_iam_role" "instance" {
  name                 = "${var.name_prefix}-semantics-ec2-role"
  permissions_boundary = var.permissions_boundary_arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "data_access" {
  name = "${var.name_prefix}-semantics-data"
  role = aws_iam_role.instance.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
        ]
        Resource = length(var.secret_arns) == 0 ? ["*"] : var.secret_arns
      },
      {
        Effect = "Allow"
        Action = [
          "redshift-data:ExecuteStatement",
          "redshift-data:DescribeStatement",
          "redshift-data:GetStatementResult",
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name_prefix}-semantics-profile"
  role = aws_iam_role.instance.name
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.name_prefix}-semantics-"
  image_id      = var.ami_id == null ? data.aws_ami.ubuntu.id : var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }

  vpc_security_group_ids = [var.workload_security_group_id]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tftpl", {
    proxy_host       = var.proxy_host
    proxy_port       = var.proxy_port
    repo_server_host = var.repo_server_host
    repo_server_port = var.repo_server_port
  }))
}

resource "aws_autoscaling_group" "this" {
  name                = "${var.name_prefix}-semantics-asg"
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-semantics"
    propagate_at_launch = true
  }
}
