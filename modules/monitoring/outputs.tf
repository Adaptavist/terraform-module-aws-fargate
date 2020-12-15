output "sns_alarm_topic_arn" {
  value = aws_sns_topic.alarm.arn
}

output "sns_slack_notification_topic_arn" {
  value = var.slack_webhook_url != "" ? module.slack-notification.* [0].alarms_topic_arn : null
}