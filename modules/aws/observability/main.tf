resource "aws_sns_topic" "alerts" {
  name = "${var.name_prefix}-platform-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  for_each = toset(var.alert_email_endpoints)

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = each.value
}

resource "aws_cloudwatch_metric_alarm" "redshift_cpu" {
  count = var.redshift_cluster_identifier == null ? 0 : 1

  alarm_name          = "${var.name_prefix}-redshift-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/Redshift"
  period              = 300
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ClusterIdentifier = var.redshift_cluster_identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  count = var.rds_identifier == null ? 0 : 1

  alarm_name          = "${var.name_prefix}-rds-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBInstanceIdentifier = var.rds_identifier
  }
}

resource "aws_cloudwatch_metric_alarm" "dms_cpu" {
  count = var.dms_replication_instance_identifier == null ? 0 : 1

  alarm_name          = "${var.name_prefix}-dms-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/DMS"
  period              = 300
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ReplicationInstanceIdentifier = var.dms_replication_instance_identifier
  }
}
