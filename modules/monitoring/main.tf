resource "aws_sns_topic" "alarm" {
  name            = "${var.fargate_service_name}-alarms-topic"
  delivery_policy = file("${path.module}/aws_sns_topic.delivery_policy.json")

  kms_master_key_id = "alias/aws/sns"

  tags = var.tags
}

module "slack-notification" {
  count = var.enable_slack_notifications ? 1 : 0

  source            = "Adaptavist/aws-alarms-slack/module"
  version           = "1.14.0"
  namespace         = var.namespace
  description       = "Slack notifications for ${var.fargate_service_name}"
  function_name     = "slack-notifications-${var.fargate_service_name}"
  stage             = var.env
  slack_webhook_url = var.slack_webhook_url
  tags              = var.tags
  include_region    = var.include_region
  aws_region        = var.region
}

resource "aws_cloudwatch_metric_alarm" "request_count" {
  count = var.create_request_count_alarm ? length(var.monitoring_config) : 0

  alarm_name          = "${var.fargate_service_name}-num-requests"
  comparison_operator = "LessThanLowerOrGreaterThanUpperThreshold"
  threshold_metric_id = "e1"
  evaluation_periods  = "2"
  alarm_description   = "Inbound traffic to ${var.fargate_service_name}"
  treat_missing_data  = var.alarm_data_missing_action
  alarm_actions       = concat([aws_sns_topic.alarm.arn], var.slack_webhook_url != "" ? [module.slack-notification.* [0].alarms_topic_arn] : [])

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1)"
    label       = "RequestCount (Expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"

    metric {
      metric_name = "RequestCount"
      namespace   = "AWS/ApplicationELB"
      period      = "300"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        LoadBalancer = var.monitoring_config[count.index].load_balancer_arn_suffix
        TargetGroup  = var.monitoring_config[count.index].target_group_arn_suffix
      }
    }
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "success_responses" {
  count = var.create_request_count_alarm ? length(var.monitoring_config) : 0

  alarm_name          = "${var.fargate_service_name}-success-responses"
  comparison_operator = "LessThanThreshold"
  threshold           = var.monit_resp_success_percentage
  evaluation_periods  = "2"
  alarm_description   = "2xx responses from ${var.fargate_service_name}"
  treat_missing_data  = var.alarm_data_missing_action
  alarm_actions       = concat([aws_sns_topic.alarm.arn], var.slack_webhook_url != "" ? [module.slack-notification.* [0].alarms_topic_arn] : [])

  metric_query {
    id          = "success"
    expression  = "ok/req*100"
    label       = "2xx Rate"
    return_data = "true"
  }

  metric_query {
    id = "req"

    metric {
      metric_name = "RequestCount"
      namespace   = "AWS/ApplicationELB"
      period      = "300"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        LoadBalancer = var.monitoring_config[count.index].load_balancer_arn_suffix
        TargetGroup  = var.monitoring_config[count.index].target_group_arn_suffix
      }
    }
  }

  metric_query {
    id = "ok"

    metric {
      metric_name = "HTTPCode_Target_2XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = "300"
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        LoadBalancer = var.monitoring_config[count.index].load_balancer_arn_suffix
        TargetGroup  = var.monitoring_config[count.index].target_group_arn_suffix
      }
    }
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "connection_error_count" {
  count = var.create_request_count_alarm ? length(var.monitoring_config) : 0

  alarm_name          = "${var.fargate_service_name}-conx-error-count"
  statistic           = "Sum"
  metric_name         = "TargetConnectionErrorCount"
  comparison_operator = "GreaterThanThreshold"
  threshold           = "0"
  evaluation_periods  = "2"
  period              = "300"
  namespace           = "AWS/ApplicationELB"
  alarm_description   = "Connection error count between ALB and ${var.fargate_service_name}"
  alarm_actions       = concat([aws_sns_topic.alarm.arn], var.slack_webhook_url != "" ? [module.slack-notification.* [0].alarms_topic_arn] : [])

  dimensions = {
    LoadBalancer = var.monitoring_config[count.index].load_balancer_arn_suffix
    TargetGroup  = var.monitoring_config[count.index].target_group_arn_suffix
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "target_response_time" {
  count = var.create_request_count_alarm ? length(var.monitoring_config) : 0

  alarm_name          = "${var.fargate_service_name}-target-resp-time"
  extended_statistic  = "p95"
  metric_name         = "TargetResponseTime"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = var.monit_target_response_time
  evaluation_periods  = "2"
  period              = "300"
  namespace           = "AWS/ApplicationELB"
  alarm_description   = "Response time from ${var.fargate_service_name}"
  treat_missing_data  = var.alarm_data_missing_action
  alarm_actions       = concat([aws_sns_topic.alarm.arn], var.slack_webhook_url != "" ? [module.slack-notification.* [0].alarms_topic_arn] : [])

  dimensions = {
    LoadBalancer = var.monitoring_config[count.index].load_balancer_arn_suffix
    TargetGroup  = var.monitoring_config[count.index].target_group_arn_suffix
  }
  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_host_count" {
  count = var.create_request_count_alarm ? length(var.monitoring_config) : 0

  alarm_name          = "${var.fargate_service_name}-unhealthy-hosts"
  statistic           = "Maximum"
  metric_name         = "UnHealthyHostCount"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = floor(var.desired_count / 2)
  evaluation_periods  = "2"
  period              = "300"
  namespace           = "AWS/ApplicationELB"
  alarm_description   = "Unhealth instances of ${var.fargate_service_name}"
  treat_missing_data  = "breaching"
  alarm_actions       = concat([aws_sns_topic.alarm.arn], var.slack_webhook_url != "" ? [module.slack-notification.* [0].alarms_topic_arn] : [])

  dimensions = {
    LoadBalancer = var.monitoring_config[count.index].load_balancer_arn_suffix
    TargetGroup  = var.monitoring_config[count.index].target_group_arn_suffix
  }
  tags = var.tags
}
