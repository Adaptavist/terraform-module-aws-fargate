variable "tags" {
  type        = map(string)
  description = "A set of tags that will be applied to all resources created by this module"
}

variable "service_name" {
  type        = string
  description = "Fargate service name"
}

variable "ecs_cluster_name" {
  type        = string
  description = "ESC cluster name"
}

variable "min_count" {
  type        = number
  description = "Minimum number of tasks in the service, used only when autoscaling is enabled"
}

variable "max_count" {
  type        = number
  description = "Maximum number of tasks in the service, used only when autoscaling is enabled"
}

variable "memory_utilization_low_period" {
  type        = number
  description = "Duration of the monitoring period"
}

variable "memory_utilization_low_threshold" {
  type        = number
  description = "Low memory threshold"
}

variable "memory_utilization_high_period" {
  type        = number
  description = "Duration of the monitoring period"
}

variable "memory_utilization_high_threshold" {
  type        = number
  description = "High memory threshold"
}

variable "cpu_utilization_low_period" {
  type        = number
  description = "Duration of the monitoring period"
}

variable "cpu_utilization_low_threshold" {
  type        = number
  description = "Low CPU threshold"
}

variable "cpu_utilization_high_period" {
  type        = number
  description = "Duration of the monitoring period"
}

variable "cpu_utilization_high_threshold" {
  type        = number
  description = "High CPU threshold"
}

variable "slack_topic_arn" {
  type        = string
  description = "SNS topic ARN for Slack notifications"
}

variable "low_cpu_alarm_enabled" {
  type        = bool
  default     = true
  description = "Indicates if the low cpu alarm is enabled"
}

variable "low_resource_consumption_alerts_enabled" {
  type        = bool
  default     = false
  description = "Indicates if Slack alerts should be enabled for low CPU/Memory consumption"
}

variable "cpu_utilization_threshold_statistic" {
  type        = string
  description = "The statistic to apply to the alarm's associated metric. Either of the following is supported: SampleCount, Average, Sum, Minimum, Maximum"

  validation {
    condition     = contains(["SampleCount", "Average", "Sum", "Minimum", "Maximum"], var.cpu_utilization_threshold_statistic)
    error_message = "must be one of: SampleCount, Average, Sum, Minimum, Maximum."
  }
}

variable "memory_utilization_threshold_statistic" {
  type        = string
  description = "The statistic to apply to the alarm's associated metric. Either of the following is supported: SampleCount, Average, Sum, Minimum, Maximum"

  validation {
    condition     = contains(["SampleCount", "Average", "Sum", "Minimum", "Maximum"], var.memory_utilization_threshold_statistic)
    error_message = "must be one of: SampleCount, Average, Sum, Minimum, Maximum."
  }
}
