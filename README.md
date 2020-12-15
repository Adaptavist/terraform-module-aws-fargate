# AWS Fargate module

This module creates a set of AWS resources: 

- AWS ECS Fargate Service
- AWS Security group for the Fargate Service
- A set of monitoring resources including Slack notifications

## Variables

| Name                                 | Type    | Default       | Required   | Description                                                                
| ------------------------------------ | ------- | ------------- | ---------- | -------------------------------------------------------------------------- 
| region                               | string  |               | âœ“        | AWS Region the Fargate service is deployed to                                      
| vpc_id                               | string  |               | âœ“        | VPC id                                       
| subnet_ids                           | list    |               | âœ“        | A list of subnet ids the fargate service will be deployed to                  
| sg_egress_cidr_blocks                | list    | ["0.0.0.0/0"] |            | List of egress CIDR blocks that will be applied to the created Fargate service
| ingress_sg_list                      | list    | []            |            | List of ingress security groups that will be applied to the created Fargate service
| alb_sg_id                            | string  |               | âœ“        | he ID of your target ALBs security to allow ingress                            
| port                                 | integer | 5060          |            | The port the service is available from                                                
| protocol                             | string  | HTTP          |            | Protocol used by the service. options: HTTP, HTTPS
| ecs_cluster_arn                      | string  |               | âœ“        | ECS cluster ARN
| ecr_repo_arn                         | string  |               | âœ“        | ECR repository ARN
| assign_public_ip                     | bool    | false         |            | Set if Fargate service should have public IP address
| sg_list                              | list    | []            |            | List of security groups that will be applied to the created Fargate service
| task_definition                      | string  |               | âœ“        | The family and revision (family:revision) or full ARN of the task definition that you want to run in your service
| desired_count                        | integer |               | âœ“        | Desired number of container instances running
| min_healthy_percent                  | integer | 100           |            | Min percent of healthy container instances
| max_percent                          | integer | 200           |            | Max percent of healthy container instances
| target_group_arns                    | list    |               | âœ“        | A list of target group ARNs
| fargate_platform_version             | string  | LATEST        |            | The version of the Fargate platform
| create_connection_error_alarm        | bool    | false         |            | Set to true if connection error alarm should be created
| create_target_response_time_alarm    | bool    | false         |            | Set to true if target response alarm should be created
| create_unhealthy_host_count_alarm    | bool    | false         |            | Set to true if unhealthy host count alarm should be created
| create_request_count_alarm           | bool    | false         |            | Set to true if request count alarm should be created
| create_success_responses_alarm       | bool    | false         |            | Set to true if success responses alarm should be created
| alarm_data_missing_action            | string  | missing       |            | Missing data action for success responses alarm. Possible values: missing or breaching
| alb_arn_and_target_groups_to_monitor | map     |               |            | A map representing albs and target groups that will be monitored with cloudwatch. Mandatory if any of the above alarms are to be set
| enable_slack_notifications           | bool    | false         |            | Indicates if slack notifications should be enabled or not. If true, slack_webhook_url must be provided.
| slack_webhook_url                    | string  |               |            | Slack webhook URL for Cloudwatch alarm notifications
| monit_resp_success_percentage        | string  | 99            | âœ“        | What percentage of requests should be responded to with 2xx
| monit_target_response_time           | string  | 0.5           | âœ“        | Service response time in seconds greater than or equal to
| namespace                            | string  |               | âœ“        | Namespace used for labeling resources                  
| name                                 | string  | fargate       |            | Name of the module / resources                         
| stage                                | string  |               | âœ“        | What staga are the resources for? staging, production? 
| tags                                 | map     |               | âœ“        | Map of tags to be applied to all resources 

## Outputs

| Name                             | Description                                                       |
| -------------------------------- | ----------------------------------------------------------------- |
| target_group_id                  | ALB Target group id for the created Fargate service               |
| target_group_arn                 | ALB Target group ARN for the created Fargate service              |
| aws_cloudwatch_log_group_arn     | Cloudwatch log group ARN                                          |
| fargate_service_name             | Fargate Service name                                              |
| sns_alarm_topic_arn              | The ARN of the SNS topic where Cloudwatch alarms will be published|
| sns_silent_alarm_topic_arn       | Same as above but for Staging environment                         |
| sns_slack_notification_topic_arn | The ARN of the SNS topic used for Slack notifications             |
