resource "aws_appautoscaling_target" "default" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${var.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.min_count
  max_capacity       = var.max_count
  tags               = var.tags
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.service_name}-high-cpu-autoscaling"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.cpu_utilization_high_period
  statistic           = var.cpu_utilization_threshold_statistic
  threshold           = var.cpu_utilization_high_threshold

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.service_name
  }

  alarm_actions = [
    aws_appautoscaling_policy.cpu_scale_up.arn
  ]
}

resource "aws_appautoscaling_policy" "cpu_scale_up" {
  name               = "cpu-scaling-up-${var.service_name}"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.default.resource_id
  scalable_dimension = aws_appautoscaling_target.default.scalable_dimension
  service_namespace  = aws_appautoscaling_target.default.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = var.cpu_utilization_threshold_statistic

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [aws_appautoscaling_target.default]
}

resource "aws_cloudwatch_metric_alarm" "mem_high" {
  alarm_name          = "${var.service_name}-high-mem-autoscaling"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.memory_utilization_high_period
  statistic           = var.memory_utilization_threshold_statistic
  threshold           = var.memory_utilization_high_threshold

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.service_name
  }

  alarm_actions = [
    aws_appautoscaling_policy.mem_scale_up.arn
  ]
}

resource "aws_appautoscaling_policy" "mem_scale_up" {
  name               = "mem-scaling-up-${var.service_name}"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.default.resource_id
  scalable_dimension = aws_appautoscaling_target.default.scalable_dimension
  service_namespace  = aws_appautoscaling_target.default.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = var.memory_utilization_threshold_statistic

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [aws_appautoscaling_target.default]
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.service_name}-low-cpu-autoscaling"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.cpu_utilization_low_period
  statistic           = var.cpu_utilization_threshold_statistic
  threshold           = var.cpu_utilization_low_threshold

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.service_name
  }

  alarm_actions = [
    aws_appautoscaling_policy.cpu_scale_down.arn
  ]
}

resource "aws_appautoscaling_policy" "cpu_scale_down" {
  name               = "cpu-scaling-down-${var.service_name}"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.default.resource_id
  scalable_dimension = aws_appautoscaling_target.default.scalable_dimension
  service_namespace  = aws_appautoscaling_target.default.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = var.cpu_utilization_threshold_statistic

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.default]
}

resource "aws_cloudwatch_metric_alarm" "mem_low" {
  alarm_name          = "${var.service_name}-low-mem-autoscaling"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.memory_utilization_low_period
  statistic           = var.memory_utilization_threshold_statistic
  threshold           = var.memory_utilization_low_threshold

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.service_name
  }

  alarm_actions = [
    aws_appautoscaling_policy.mem_scale_down.arn
  ]
}

resource "aws_appautoscaling_policy" "mem_scale_down" {
  name               = "mem-scaling-down-${var.service_name}"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.default.resource_id
  scalable_dimension = aws_appautoscaling_target.default.scalable_dimension
  service_namespace  = aws_appautoscaling_target.default.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = var.memory_utilization_threshold_statistic

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.default]
}
