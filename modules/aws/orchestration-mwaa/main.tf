data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "execution" {
  name                 = "${var.name_prefix}-mwaa-execution-role"
  permissions_boundary = var.permissions_boundary_arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = [
          "airflow.amazonaws.com",
          "airflow-env.amazonaws.com",
        ]
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "execution" {
  name = "${var.name_prefix}-mwaa-execution"
  role = aws_iam_role.execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
        ]
        Resource = [
          var.dag_bucket_arn,
          "${var.dag_bucket_arn}/*",
          var.log_bucket_arn,
          "${var.log_bucket_arn}/*",
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:GetLogRecord",
          "logs:GetLogGroupFields",
          "logs:GetQueryResults",
          "logs:DescribeLogGroups",
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:airflow-${var.name_prefix}-mwaa-*"
      },
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction",
        ]
        Resource = length(var.lambda_function_arns) == 0 ? ["*"] : values(var.lambda_function_arns)
      },
      {
        Effect = "Allow"
        Action = [
          "glue:StartJobRun",
          "glue:GetJobRun",
          "glue:GetJobRuns",
          "glue:GetJob",
        ]
        Resource = length(var.glue_job_arns) == 0 ? ["*"] : values(var.glue_job_arns)
      },
      {
        Effect = "Allow"
        Action = [
          "dms:StartReplicationTask",
          "dms:StopReplicationTask",
          "dms:DescribeReplicationTasks",
        ]
        Resource = length(var.dms_task_arns) == 0 ? ["*"] : values(var.dms_task_arns)
      },
      {
        Effect = "Allow"
        Action = [
          "redshift-data:ExecuteStatement",
          "redshift-data:DescribeStatement",
          "redshift-data:GetStatementResult",
          "redshift-data:CancelStatement",
        ]
        Resource = "*"
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

resource "aws_mwaa_environment" "this" {
  name               = "${var.name_prefix}-mwaa"
  airflow_version    = var.airflow_version
  environment_class  = var.environment_class
  execution_role_arn = aws_iam_role.execution.arn

  source_bucket_arn    = var.dag_bucket_arn
  dag_s3_path          = var.dag_s3_path
  requirements_s3_path = var.requirements_s3_path

  min_workers = var.min_workers
  max_workers = var.max_workers
  schedulers  = var.schedulers

  webserver_access_mode = "PUBLIC_ONLY"

  network_configuration {
    security_group_ids = [var.workload_security_group_id]
    subnet_ids         = var.private_subnet_ids
  }

  logging_configuration {
    dag_processing_logs {
      enabled   = true
      log_level = "INFO"
    }

    scheduler_logs {
      enabled   = true
      log_level = "INFO"
    }

    task_logs {
      enabled   = true
      log_level = "INFO"
    }

    webserver_logs {
      enabled   = true
      log_level = "INFO"
    }

    worker_logs {
      enabled   = true
      log_level = "INFO"
    }
  }
}
