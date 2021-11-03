resource "aws_cloudwatch_metric_alarm" "cpu_utilisation_high" {
  alarm_name          = "${var.service_name}-cpu-utilisation-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.cpu_utilization_high_period
  statistic           = "Average"
  threshold           = var.cpu_utilization_high_threshold
  treat_missing_data  = "notBreaching"

  alarm_description = format(
    "Average service %v utilization %v last %d minute(s) over %v period(s)",
    "CPU",
    "High",
    var.cpu_utilization_high_period / 60,
    1
  )

  alarm_actions = compact([var.slack_topic_arn, module.ecs_cloudwatch_autoscaling_cpu.scale_up_policy_arn])

  ok_actions = compact([var.slack_topic_arn])

  dimensions = {
    "ClusterName" = var.ecs_cluster_name
    "ServiceName" = var.service_name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilisation_low" {
  alarm_name          = "${var.service_name}-cpu-utilisation-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.cpu_utilization_low_period
  statistic           = "Average"
  threshold           = var.cpu_utilization_low_threshold
  treat_missing_data  = "notBreaching"

  alarm_description = format(
    "Average service %v utilization %v last %d minute(s) over %v period(s)",
    "CPU",
    "Low",
    var.cpu_utilization_low_period / 60,
    1
  )

  ok_actions    = []
  alarm_actions = [module.ecs_cloudwatch_autoscaling_cpu.scale_down_policy_arn]

  dimensions = {
    "ClusterName" = var.ecs_cluster_name
    "ServiceName" = var.service_name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "memory_utilisation_high" {
  alarm_name          = "${var.service_name}-memory-utilisation-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.memory_utilization_high_period
  statistic           = "Average"
  threshold           = var.memory_utilization_high_threshold
  treat_missing_data  = "notBreaching"

  alarm_description = format(
    "Average service %v utilization %v last %d minute(s) over %v period(s)",
    "Memory",
    "High",
    var.memory_utilization_high_period / 60,
    1
  )

  alarm_actions = compact([var.slack_topic_arn, module.ecs_cloudwatch_autoscaling_memory.scale_up_policy_arn])
  ok_actions    = compact([var.slack_topic_arn])

  dimensions = {
    "ClusterName" = var.ecs_cluster_name
    "ServiceName" = var.service_name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "memory_utilisation_low" {
  alarm_name          = "${var.service_name}-memory-utilisation-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.memory_utilization_low_period
  statistic           = "Average"
  threshold           = var.memory_utilization_low_threshold
  treat_missing_data  = "notBreaching"

  alarm_description = format(
    "Average service %v utilization %v last %d minute(s) over %v period(s)",
    "Memory",
    "Low",
    var.memory_utilization_low_period / 60,
    1
  )
  alarm_actions = [module.ecs_cloudwatch_autoscaling_memory.scale_down_policy_arn]
  ok_actions    = []

  dimensions = {
    "ClusterName" = var.ecs_cluster_name
    "ServiceName" = var.service_name
  }

  tags = var.tags
}
