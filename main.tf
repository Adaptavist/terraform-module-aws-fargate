module "labels" {
  source = "git::https://github.com/cloudposse/terraform-null-label.git?ref=488ab91e34a24a86957e397d9f7262ec5925586a" # <- version 0.25.0

  namespace = var.namespace
  stage     = var.stage
  name      = var.name
  tags      = var.tags
}

locals {
  // If an alarm threshold is provided, use it, otherwise use the autoscaling threshold
  cpu_utilization_high_alarm_threshold    = var.cpu_utilization_high_alarm_threshold != null ? var.cpu_utilization_high_alarm_threshold : var.cpu_utilization_high_threshold
  memory_utilization_high_alarm_threshold = var.memory_utilization_high_alarm_threshold != null ? var.memory_utilization_high_alarm_threshold : var.memory_utilization_high_threshold
}

resource "aws_security_group" "this" {
  #checkov:skip=CKV_AWS_23:security group description forces re-creation.
  name_prefix = "${module.labels.id}-"
  vpc_id      = var.vpc_id

  tags = module.labels.tags
}

resource "aws_security_group_rule" "egress" {
  #checkov:skip=CKV_AWS_23:security group description forces re-creation.
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  cidr_blocks       = var.sg_egress_cidr_blocks
  ipv6_cidr_blocks  = ["::/0"]
  type              = "egress"
  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "ingress" {
  for_each = nonsensitive(toset(var.ingress_sg_list))

  description              = "Load Balancer Ingress"
  from_port                = var.port
  protocol                 = "TCP"
  to_port                  = var.port
  source_security_group_id = each.value
  type                     = "ingress"
  security_group_id        = aws_security_group.this.id

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_ecs_task_definition" "this" {
  task_definition = var.task_definition
}

resource "aws_ecs_service" "fargate" {
  count                              = var.enable_codedeploy_control ? 0 : 1
  name                               = module.labels.id
  task_definition                    = "${data.aws_ecs_task_definition.this.family}:${data.aws_ecs_task_definition.this.revision}"
  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = var.min_healthy_percent
  deployment_maximum_percent         = var.max_percent
  cluster                            = var.ecs_cluster_arn
  launch_type                        = "FARGATE"
  platform_version                   = var.fargate_platform_version
  health_check_grace_period_seconds  = var.health_check_grace_period
  availability_zone_rebalancing      = var.availability_zone_rebalancing

  network_configuration {
    subnets          = var.subnet_ids
    assign_public_ip = var.assign_public_ip
    security_groups  = concat(var.sg_list, [aws_security_group.this.id])
  }

  dynamic "load_balancer" {
    for_each = [for tg in toset(var.target_group_arns) : { arn = tg }]

    content {
      target_group_arn = load_balancer.value.arn
      container_name   = var.name
      container_port   = var.port
    }
  }

  wait_for_steady_state = var.wait_for_steady_state

  propagate_tags = "TASK_DEFINITION"
  tags           = module.labels.tags

  deployment_controller {
    type = var.deployment_controller
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_ecs_service" "fargate-codedeploy" {
  count                              = var.enable_codedeploy_control ? 1 : 0
  name                               = module.labels.id
  task_definition                    = "${data.aws_ecs_task_definition.this.family}:${data.aws_ecs_task_definition.this.revision}"
  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = var.min_healthy_percent
  deployment_maximum_percent         = var.max_percent
  cluster                            = var.ecs_cluster_arn
  launch_type                        = "FARGATE"
  platform_version                   = var.fargate_platform_version
  health_check_grace_period_seconds  = var.health_check_grace_period

  network_configuration {
    subnets          = var.subnet_ids
    assign_public_ip = var.assign_public_ip
    security_groups  = concat(var.sg_list, [aws_security_group.this.id])
  }

  dynamic "load_balancer" {
    for_each = [for tg in toset(var.target_group_arns) : { arn = tg }]

    content {
      target_group_arn = load_balancer.value.arn
      container_name   = var.name
      container_port   = var.port
    }
  }

  wait_for_steady_state = var.wait_for_steady_state

  propagate_tags = "TASK_DEFINITION"
  tags           = module.labels.tags

  deployment_controller {
    type = var.deployment_controller
  }

  lifecycle {
    ignore_changes = [task_definition, load_balancer, desired_count]
  }
}

module "monitoring" {
  source = "./modules/monitoring"

  region         = var.region
  env            = var.stage
  namespace      = var.namespace
  tags           = module.labels.tags
  include_region = var.include_region

  monitoring_config = var.monitoring_config

  fargate_service_name = (var.enable_codedeploy_control ? aws_ecs_service.fargate-codedeploy.*.name : aws_ecs_service.fargate.*.name)[0]
  ecs_cluster_name     = var.ecs_cluster_name
  desired_count        = var.desired_count

  enable_slack_notifications = var.enable_slack_notifications
  slack_webhook_url          = var.slack_webhook_url
  alarm_data_missing_action  = var.alarm_data_missing_action

  create_connection_error_alarm                = var.create_connection_error_alarm
  create_target_response_time_alarm            = var.create_target_response_time_alarm
  create_unhealthy_host_count_alarm            = var.create_unhealthy_host_count_alarm
  create_request_count_alarm                   = var.create_request_count_alarm
  create_success_responses_alarm               = var.create_success_responses_alarm
  monit_resp_success_percentage                = var.monit_resp_success_percentage
  monit_target_response_time                   = var.monit_target_response_time
  monit_target_response_time_evaluation_period = var.monit_target_response_time_evaluation_period
  anomaly_detection_width                      = var.anomaly_detection_width
  request_count_high_threshold                 = var.request_count_high_threshold
  request_count_low_threshold                  = var.request_count_low_threshold

  cpu_utilization_high_threshold         = local.cpu_utilization_high_alarm_threshold
  cpu_utilization_threshold_statistic    = var.cpu_utilization_threshold_statistic
  memory_utilization_high_threshold      = local.memory_utilization_high_alarm_threshold
  memory_utilization_threshold_statistic = var.memory_utilization_threshold_statistic
}

module "autoscaling" {
  source = "./modules/autoscaling"
  count  = var.enable_autoscaling ? 1 : 0

  ecs_cluster_name = var.ecs_cluster_name
  service_name     = (var.enable_codedeploy_control ? aws_ecs_service.fargate-codedeploy.*.name : aws_ecs_service.fargate.*.name)[0]
  max_count        = var.max_count
  min_count        = var.min_count

  cpu_utilization_high_period            = var.cpu_utilization_high_period
  cpu_utilization_high_threshold         = var.cpu_utilization_high_threshold
  cpu_utilization_low_period             = var.cpu_utilization_low_period
  cpu_utilization_low_threshold          = var.cpu_utilization_low_threshold
  cpu_utilization_threshold_statistic    = var.cpu_utilization_threshold_statistic
  memory_utilization_high_period         = var.memory_utilization_high_period
  memory_utilization_high_threshold      = var.memory_utilization_high_threshold
  memory_utilization_low_period          = var.memory_utilization_low_period
  memory_utilization_low_threshold       = var.memory_utilization_low_threshold
  memory_utilization_threshold_statistic = var.memory_utilization_threshold_statistic

  tags = module.labels.tags
}
