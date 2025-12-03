resource "aws_cloudwatch_metric_alarm" "cpu_utilisation_high" {
  alarm_name          = "${var.service_name}-cpu-utilisation-high-autoscaling"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.cpu_utilization_high_period
  statistic           = var.cpu_utilization_threshold_statistic
  threshold           = var.cpu_utilization_high_threshold
  treat_missing_data  = "notBreaching"

  alarm_description = format(
    "%v service %v utilization %v last %d minute(s) over %v period(s)",
    var.cpu_utilization_threshold_statistic,
    "CPU",
    "High",
    var.cpu_utilization_high_period / 60,
    1
  )

  alarm_actions = [aws_appautoscaling_policy.cpu_scale_up.arn]

  ok_actions = []

  dimensions = {
    "ClusterName" = var.ecs_cluster_name
    "ServiceName" = var.service_name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilisation_low" {
  alarm_name          = "${var.service_name}-cpu-utilisation-low-autoscaling"
  comparison_operator = var.cpu_utilization_low_threshold == 0 ? "LessThanOrEqualToThreshold" : "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.cpu_utilization_low_period
  statistic           = var.cpu_utilization_threshold_statistic
  threshold           = var.cpu_utilization_low_threshold
  treat_missing_data  = "notBreaching"

  alarm_description = format(
    "%v service %v utilization %v last %d minute(s) over %v period(s)",
    var.cpu_utilization_threshold_statistic,
    "CPU",
    "Low",
    var.cpu_utilization_low_period / 60,
    1
  )

  ok_actions    = []
  alarm_actions = [aws_appautoscaling_policy.cpu_scale_down.arn]

  dimensions = {
    "ClusterName" = var.ecs_cluster_name
    "ServiceName" = var.service_name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "memory_utilisation_high" {
  alarm_name          = "${var.service_name}-memory-utilisation-high-autoscaling"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.memory_utilization_high_period
  statistic           = var.memory_utilization_threshold_statistic
  threshold           = var.memory_utilization_high_threshold
  treat_missing_data  = "notBreaching"

  alarm_description = format(
    "%v service %v utilization %v last %d minute(s) over %v period(s)",
    var.memory_utilization_threshold_statistic,
    "Memory",
    "High",
    var.memory_utilization_high_period / 60,
    1
  )

  alarm_actions = [aws_appautoscaling_policy.mem_scale_up.arn]
  ok_actions    = []

  dimensions = {
    "ClusterName" = var.ecs_cluster_name
    "ServiceName" = var.service_name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "memory_utilisation_low" {
  alarm_name          = "${var.service_name}-memory-utilisation-low-autoscaling"
  comparison_operator = var.memory_utilization_low_threshold == 0 ? "LessThanOrEqualToThreshold" : "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.memory_utilization_low_period
  statistic           = var.memory_utilization_threshold_statistic
  threshold           = var.memory_utilization_low_threshold
  treat_missing_data  = "notBreaching"

  alarm_description = format(
    "%v service %v utilization %v last %d minute(s) over %v period(s)",
    var.memory_utilization_threshold_statistic,
    "Memory",
    "Low",
    var.memory_utilization_low_period / 60,
    1
  )
  alarm_actions = [aws_appautoscaling_policy.mem_scale_down.arn]
  ok_actions    = []

  dimensions = {
    "ClusterName" = var.ecs_cluster_name
    "ServiceName" = var.service_name
  }

  tags = var.tags
}
