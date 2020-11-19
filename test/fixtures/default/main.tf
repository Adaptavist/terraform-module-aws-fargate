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

resource aws_ecs_cluster "this" {
  name = "test"
  tags = local.tags
}

module "this" {
  source                                      = "../../.."
  namespace                                   = "avst-tf"
  stage                                       = "stg"
  name                                        = "test"
  tags                                        = local.tags
  alb_sg_id                                   = ""
  desired_count                               = 2
  region                                      = "eu-west-1"
  slack_webhook_url                           = "slack.com/bar"
  subnet_ids                                  = [for s in data.aws_subnet.example : s.id]
  task_definition                             = ""
  vpc_id                                      = data.aws_vpc.default.id
  ecs_cluster_arn                             = aws_ecs_cluster.this.arn
  alb_and_target_groups_monitoring_dimensions = {}
}

data aws_caller_identity "current" {}

data aws_vpc "default" {
  default = true
}

data aws_subnet_ids "this" {
  vpc_id = data.aws_vpc.default.id
}

data aws_subnet "example" {
  for_each = data.aws_subnet_ids.this.ids
  id       = each.value
}



