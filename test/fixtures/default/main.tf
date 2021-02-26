locals {
  tags = {
    "Avst:Project"      = "testproject"
    "Avst:BusinessUnit" = "testbu"
    "Avst:CostCenter"   = "testCC"
    "Avst:Team"         = "testteam"
    "Avst:Stage:Name"   = "stage"
    "Avst:Stage:Type"   = "integration"
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_ecs_cluster" "this" {
  name = "test"
  tags = local.tags
}

resource "aws_ecs_task_definition" "this" {
  container_definitions    = file("service.json")
  family                   = "hello-world"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "2048"
  memory                   = "4096"
}

resource "aws_lb_target_group" "ip-example" {
  name        = "tf-example-lb-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.this.ids
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ip-example.arn
  }
}

module "this" {
  source                                      = "../../.."
  namespace                                   = "avst-tf"
  stage                                       = "stg"
  name                                        = "hello-world"
  tags                                        = local.tags
  alb_sg_id                                   = ""
  desired_count                               = 2
  region                                      = "eu-west-1"
  slack_webhook_url                           = "slack.com/bar"
  enable_slack_notifications                  = true
  subnet_ids                                  = [for s in data.aws_subnet.example : s.id]
  task_definition                             = aws_ecs_task_definition.this.id
  vpc_id                                      = data.aws_vpc.default.id
  ecs_cluster_arn                             = aws_ecs_cluster.this.arn
  alb_and_target_groups_monitoring_dimensions = {}
  target_group_arns                           = [aws_lb_target_group.ip-example.arn]
  port                                        = 80
}

data "aws_caller_identity" "current" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "this" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_subnet" "example" {
  for_each = data.aws_subnet_ids.this.ids
  id       = each.value
}




