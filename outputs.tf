output "fargate_service_name" {
  value = var.enable_codedeploy_control ? aws_ecs_service.fargate-codedeploy.*.name : aws_ecs_service.fargate.*.name
}

output "security_group_id" {
  value = aws_security_group.this.id
}

output "sns_alarm_topic_arn" {
  value = module.monitoring.sns_alarm_topic_arn
}

output "sns_slack_notification_topic_arn" {
  value = module.monitoring.sns_slack_notification_topic_arn
}
