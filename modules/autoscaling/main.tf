module "ecs_cloudwatch_autoscaling_cpu" {
  source  = "cloudposse/ecs-cloudwatch-autoscaling/aws"
  version = "0.7.0"

  name                  = var.service_name
  attributes            = ["cpu"]
  label_order           = ["name", "attributes"]
  service_name          = var.service_name
  cluster_name          = var.ecs_cluster_name
  min_capacity          = var.min_count
  max_capacity          = var.max_count
  scale_up_adjustment   = 1
  scale_up_cooldown     = 60
  scale_down_adjustment = -1
  scale_down_cooldown   = 300

  tags = var.tags
}

module "ecs_cloudwatch_autoscaling_memory" {
  source  = "cloudposse/ecs-cloudwatch-autoscaling/aws"
  version = "0.7.0"

  name                  = var.service_name
  attributes            = ["memory"]
  label_order           = ["name", "attributes"]
  service_name          = var.service_name
  cluster_name          = var.ecs_cluster_name
  min_capacity          = var.min_count
  max_capacity          = var.max_count
  scale_up_adjustment   = 1
  scale_up_cooldown     = 60
  scale_down_adjustment = -1
  scale_down_cooldown   = 300

  tags = var.tags
}
