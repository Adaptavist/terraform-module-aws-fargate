module "ecs_cloudwatch_autoscaling_cpu" {
  source = "git::https://github.com/cloudposse/terraform-aws-ecs-cloudwatch-autoscaling.git?ref=b8d39a739e9dcf28f29b3c152b6dba29e8718d20" # <- version 0.7.5

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
  source = "git::https://github.com/cloudposse/terraform-aws-ecs-cloudwatch-autoscaling.git?ref=b8d39a739e9dcf28f29b3c152b6dba29e8718d20" # <- version 0.7.5

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

  depends_on = [module.ecs_cloudwatch_autoscaling_cpu]
}
