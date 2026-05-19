resource "aws_iam_role" "this" {
  name                 = "${var.name_prefix}-ingestion-lambda-role"
  permissions_boundary = var.permissions_boundary_arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "vpc" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "data_access" {
  name = "${var.name_prefix}-ingestion-lambda-data"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
        ]
        Resource = concat(var.target_bucket_arns, [for arn in var.target_bucket_arns : "${arn}/*"])
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

resource "aws_cloudwatch_log_group" "this" {
  for_each = var.functions

  name              = "/aws/lambda/${var.name_prefix}-${each.key}"
  retention_in_days = var.log_retention_days
}

resource "aws_lambda_function" "this" {
  for_each = var.functions

  function_name = "${var.name_prefix}-${each.key}"
  role          = aws_iam_role.this.arn
  runtime       = each.value.runtime
  handler       = each.value.handler
  timeout       = each.value.timeout
  memory_size   = each.value.memory_size

  s3_bucket         = each.value.s3_bucket
  s3_key            = each.value.s3_key
  s3_object_version = each.value.s3_object_version

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.workload_security_group_id]
  }

  environment {
    variables = merge(each.value.environment, {
      HTTP_PROXY       = "http://${var.proxy_host}:${var.proxy_port}"
      HTTPS_PROXY      = "http://${var.proxy_host}:${var.proxy_port}"
      NO_PROXY         = "169.254.169.254,.amazonaws.com"
      RAW_BUCKET_NAME  = var.raw_bucket_name
    })
  }

  depends_on = [
    aws_cloudwatch_log_group.this,
    aws_iam_role_policy_attachment.basic,
    aws_iam_role_policy_attachment.vpc,
  ]
}
