# AWS Fargate module

This module creates a set of AWS resources:

- AWS ECS Fargate Service
- AWS Security group for the Fargate Service
- A set of monitoring resources including Slack notifications
- A set of autoscaling resources
- If autoscaling isn't enabled, desires count will match min and max count

### Autoscaling
The autoscaling is triggered by a set of cloudwatch alarms that monitor CPU and memory. Monitoring period and thresholds for each alarm are configurable.
Autoscaling resources have been configured using [Cloudposse `ecs-cloudwatch-autoscaling`](https://github.com/cloudposse/terraform-aws-ecs-cloudwatch-autoscaling) module</p>
Both scaling up and down are configured to make adjustments by adding or removing a single tasks. </p>
Scaling-up cool down period is 1 minute while scaling-down cool down period is 5 minutes.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| alarm\_data\_missing\_action | Missing data action for success responses alarm. Possible values: missing or breaching | `string` | `"missing"` | no |
| assign\_public\_ip | Assign public IP to the Fargate service | `bool` | `false` | no |
| cpu\_utilization\_high\_period | Duration of the monitoring period | `number` | `300` | no |
| cpu\_utilization\_high\_threshold | High CPU threshold | `number` | `60` | no |
| cpu\_utilization\_low\_period | Duration of the monitoring period | `number` | `300` | no |
| cpu\_utilization\_low\_threshold | Low CPU threshold | `number` | `20` | no |
| create\_connection\_error\_alarm | Set to true if connection error alarm should be created | `bool` | `false` | no |
| create\_request\_count\_alarm | Set to true if request count alarm should be created | `bool` | `false` | no |
| create\_success\_responses\_alarm | Set to true if success responses alarm should be created | `bool` | `false` | no |
| create\_target\_response\_time\_alarm | Set to true if target response time alarm should be created | `bool` | `false` | no |
| create\_unhealthy\_host\_count\_alarm | Set to true if unhealthy host count alarm should be created | `bool` | `false` | no |
| deployment\_controller | Type of deployment controller. Valid values: CODE\_DEPLOY, ECS, EXTERNAL. Default: ECS | `string` | `"ECS"` | no |
| desired\_count | desired number of container instances running | `number` | n/a | yes |
| ecs\_cluster\_arn | ECS Cluster ARN | `string` | n/a | yes |
| ecs\_cluster\_name | Name of the ECS cluster | `string` | n/a | yes |
| enable\_autoscaling | Indicate if autoscaling should be enabled or not | `bool` | `false` | no |
| enable\_codedeploy\_control | Setting this variable to true configures Fargate service terraform lifecycle to ignore changes done to the task definition and load balancer config. These will be controlled by code deploy. | `bool` | `false` | no |
| enable\_slack\_notifications | Indicates if slack notifications should be enabled or not. If true, slack\_webhook\_url must be provided. | `bool` | `false` | no |
| fargate\_platform\_version | The version of the Fargate platform | `string` | `"LATEST"` | no |
| health\_check\_grace\_period | Number of seconds that ECS service scheduler should ignore unhealthy ELB target/container/route 53 health checks after a task enters a RUNNING state | `number` | `0` | no |
| include\_region | If set to true the current providers region will be appended to any global AWS resources such as IAM roles | `bool` | `false` | no |
| ingress\_sg\_list | List of ingress security groups that will be applied to the created Fargate service | `list(string)` | `[]` | no |
| max\_count | Maximum number of tasks in the service, used only when autoscaling is enabled | `number` | `1` | no |
| max\_percent | max percent of healthy container instances | `number` | `200` | no |
| memory\_utilization\_high\_period | Duration of the monitoring period | `number` | `300` | no |
| memory\_utilization\_high\_threshold | High memory threshold | `number` | `60` | no |
| memory\_utilization\_low\_period | Duration of the monitoring period | `number` | `300` | no |
| memory\_utilization\_low\_threshold | Low memory threshold | `number` | `20` | no |
| min\_count | Minimum number of tasks in the service, used only when autoscaling is enabled | `number` | `1` | no |
| min\_healthy\_percent | min percent of healthy container instances | `number` | `100` | no |
| monit\_resp\_success\_percentage | What percentage of requests should be responded to with 2xx | `string` | `"99"` | no |
| monit\_target\_response\_time | service response time in seconds greater than or equal to | `string` | `"0.5"` | no |
| monitoring\_config | n/a | <pre>list(object({<br>    load_balancer_arn_suffix = string<br>    target_group_arn_suffix  = string<br>    // some of the defaulted properties, such as monitoring period, can be added here<br>  }))</pre> | n/a | yes |
| name | Name of the fargate instance | `string` | `"fargate"` | no |
| namespace | n/a | `string` | n/a | yes |
| port | The port the service is available from | `number` | `5060` | no |
| region | AWS Region the Fargate service is deployed to | `string` | n/a | yes |
| sg\_egress\_cidr\_blocks | List of egress CIDR blocks that will be applied to the created Fargate service | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| sg\_list | List of security groups that will be applied to the created Fargate service | `list(string)` | `[]` | no |
| slack\_webhook\_url | Slack webhook URL for Cloudwatch alarm notifications | `string` | `""` | no |
| stage | Deployment stage i.e. environment name | `string` | n/a | yes |
| subnet\_ids | A list of subnet ids the fargate service will be deployed to | `list(string)` | n/a | yes |
| tags | A set of tags that will be applied to all resources created by this module | `map(string)` | n/a | yes |
| target\_group\_arns | A list of target group ARNs | `list(string)` | `[]` | no |
| task\_definition | The family and revision (family:revision) or full ARN of the task definition that you want to run in your service | `string` | n/a | yes |
| vpc\_id | VPC Id | `string` | n/a | yes |
| wait\_for\_steady\_state | Terraform will wait for the service to reach a steady state (like aws ecs wait services-stable) before continuing | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| fargate\_service\_name | n/a |
| security\_group\_id | n/a |
| sns\_alarm\_topic\_arn | n/a |
| sns\_slack\_notification\_topic\_arn | n/a |


## Verify Module changes locally. 

In order to validate any changes in this repo locally.

1. Push your code up to a brach on BitBucket. 
2. Clone the sr-fargate-module repository. 
3. in the sr-fargate-module repository open the *main.tf* file 
4. Navigate to line 198 and change the *source* property for the *module "fargate-service"* to point to your branch by changing the value of the *ref=* part of the url to be like *ref=BranchName*. 
5. Pull the latest terraform code from the branch by running the command of *terraform init*. 

## Conventional commits

This repository uses [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/#summary). For example, to trigger a new release version, please make sure your commits match this format. 

