// labelling

variable "name" {
  type        = string
  default     = "fargate"
  description = "Name of the fargate instance"
}

variable "namespace" {
  type = string
}

variable "stage" {
  type        = string
  description = "Deployment stage i.e. environment name"
}

variable "tags" {
  type        = map(string)
  description = "A set of tags that will be applied to all resources created by this module"
}

variable "include_region" {
  type        = bool
  default     = false
  description = "If set to true the current providers region will be appended to any global AWS resources such as IAM roles"
}

variable "region" {
  type        = string
  description = "AWS Region the Fargate service is deployed to"
}

variable "vpc_id" {
  type        = string
  description = "VPC Id"
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnet ids the fargate service will be deployed to"
}

variable "sg_egress_cidr_blocks" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of egress CIDR blocks that will be applied to the created Fargate service"
}

variable "ingress_sg_list" {
  type        = list(string)
  default     = []
  description = "List of ingress security groups that will be applied to the created Fargate service"
}

variable "assign_public_ip" {
  type        = bool
  default     = false
  description = "Assign public IP to the Fargate service"
}

variable "sg_list" {
  type        = list(string)
  default     = []
  description = "List of security groups that will be applied to the created Fargate service"
}

variable "alb_sg_id" {
  type        = string
  description = "The ID of your target ALBs security to allow ingress"
}

variable "target_group_arns" {
  type        = list(string)
  default     = []
  description = "A list of target group ARNs"
}

variable "port" {
  type        = number
  default     = 5060
  description = "The port the service is available from"
}

variable "ecs_cluster_arn" {
  type        = string
  description = "ECS Cluster ARN"
}

variable "fargate_platform_version" {
  type        = string
  default     = "LATEST"
  description = "The version of the Fargate platform"
}

variable "task_definition" {
  type        = string
  description = "The family and revision (family:revision) or full ARN of the task definition that you want to run in your service"
}

variable "desired_count" {
  type        = number
  description = "desired number of container instances running"
}

variable "min_healthy_percent" {
  type        = number
  default     = 100
  description = "min percent of healthy container instances"
}

variable "max_percent" {
  type        = number
  default     = 200
  description = "max percent of healthy container instances"
}

variable "wait_for_steady_state" {
  type        = bool
  default     = false
  description = "Terraform will wait for the service to reach a steady state (like aws ecs wait services-stable) before continuing"
}

variable "health_check_grace_period" {
  type        = number
  default     = 0
  description = "Number of seconds that ECS service scheduler should ignore unhealthy ELB target/container/route 53 health checks after a task enters a RUNNING state"
}

// Monitoring

variable "create_connection_error_alarm" {
  type        = bool
  default     = false
  description = "Set to true if connection error alarm should be created"
}

variable "create_target_response_time_alarm" {
  type        = bool
  default     = false
  description = "Set to true if target response time alarm should be created"
}

variable "create_unhealthy_host_count_alarm" {
  type        = bool
  default     = false
  description = "Set to true if unhealthy host count alarm should be created"
}

variable "create_request_count_alarm" {
  type        = bool
  default     = false
  description = "Set to true if request count alarm should be created"
}

variable "create_success_responses_alarm" {
  type        = bool
  default     = false
  description = "Set to true if success responses alarm should be created"
}

variable "alarm_data_missing_action" {
  type        = string
  default     = "missing"
  description = "Missing data action for success responses alarm. Possible values: missing or breaching"
}

variable "alb_and_target_groups_monitoring_dimensions" {
  type        = map(string)
  description = "A map representing albs and target groups that will be monitored with cloudwatch"
}

variable "enable_slack_notifications" {
  type        = bool
  default     = false
  description = "Indicates if slack notifications should be enabled or not. If true, slack_webhook_url must be provided."
}

variable "slack_webhook_url" {
  type        = string
  default     = ""
  description = "Slack webhook URL for Cloudwatch alarm notifications"
}

variable "monit_resp_success_percentage" {
  type        = string
  default     = "99"
  description = "What percentage of requests should be responded to with 2xx"
}

variable "monit_target_response_time" {
  type        = string
  default     = "0.5"
  description = "service response time in seconds greater than or equal to"
}

