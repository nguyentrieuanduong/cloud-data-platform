output "alert_topic_arn" {
  description = "Output from alert topic arn."
  value = aws_sns_topic.alerts.arn
}
