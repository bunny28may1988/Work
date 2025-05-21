*** EC2 Auto-Scaling ***

### Module Usage ###

```
module "asg" {
  source = "../asg"

  ############# Launch template ###############

  launch_template_name        = "Test-asg-temp"
  launch_template_description = "Launch template example"
  update_default_version      = true

  image_id          = "ami-09298640a92b2d12c"
  instance_type     = "t3.micro"
  ebs_optimized     = true
  enable_monitoring = true
  key_name = "Terraform-genrated"
  security_groups = ["sg-04672acbf30b29bc1"]

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        kms_key_id = "arn:aws:kms:ap-south-1:110664605661:key/fa69d0fb-6fae-44d6-97c4-866b7f45ecbd"
        volume_size           = 20
        volume_type           = "gp3"
      }
    }, 
    {
      device_name = "/dev/sda1"
      no_device   = 1
      ebs = {
        delete_on_termination = true
        encrypted             = true
        kms_key_id = "arn:aws:kms:ap-south-1:110664605661:key/fa69d0fb-6fae-44d6-97c4-866b7f45ecbd"
        volume_size           = 30
        volume_type           = "gp3"
      }
    }
  ]

  iam_instance_profile_name = "SSM-Role"
  
  ########## policy attachement ###############

  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

 tags = {
  "Env" = "Dev",
  "App" = "Web",
  "Owner" = "DevOps"
 }
 ########## Autoscaling group ####################
  name            = "test-asg"
  use_name_prefix = false
  instance_name   = "Test-ASG-EC2"

  ignore_desired_capacity_changes = true

  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  default_instance_warmup   = 300
  health_check_type         = "EC2"
  vpc_zone_identifier       = ["subnet-0266e74c4c3f5c4a6","subnet-0c0ad590db57becfa"]
  #service_linked_role_arn   = aws_iam_service_linked_role.autoscaling.arn
  
  # Traffic source attachment
  create_traffic_source_attachment = true
  traffic_source_identifier        = "arn:aws:elasticloadbalancing:ap-south-1:110664605661:targetgroup/test-tg-2/daa7d8f2037a7540"
  traffic_source_type              = "elbv2"

  initial_lifecycle_hooks = [
    {
      name                  = "ExampleStartupLifeCycleHook"
      default_result        = "CONTINUE"
      heartbeat_timeout     = 60
      lifecycle_transition  = "autoscaling:EC2_INSTANCE_LAUNCHING"
      notification_metadata = jsonencode({ "Task" = "INSTANCE_LAUNCHING" })
      # notification_target_arn = "arn:aws:sns:ap-south-1:110664605661:test"
      # role_arn                = "arn:aws:iam::110664605661:role/SSM-Role"
    },
    {
      name                  = "ExampleTerminationLifeCycleHook"
      default_result        = "CONTINUE"
      heartbeat_timeout     = 180
      lifecycle_transition  = "autoscaling:EC2_INSTANCE_TERMINATING"
      notification_metadata = jsonencode({ "Task" = "INSTANCE_TERMINATING" })
      # notification_target_arn = "arn:aws:sns:ap-south-1:110664605661:test"
      # role_arn                = "arn:aws:iam::110664605661:role/SSM-Role"
    }
  ]

  instance_maintenance_policy = {
    min_healthy_percentage = 100
    max_healthy_percentage = 110
  }


   instance_refresh = {
     strategy = "Rolling"
     preferences = {
       checkpoint_delay             = 600
       checkpoint_percentages       = [35, 70, 100]
       instance_warmup              = 300
       min_healthy_percentage       = 50
       max_healthy_percentage       = 100
       auto_rollback                = true
       scale_in_protected_instances = "Refresh"
       standby_instances            = "Terminate"
       skip_matching                = false
     }
     triggers = ["tag"]
   }

 # Target scaling policy schedule based on average CPU load
  scaling_policies = {
    avg-cpu-policy-greater-than-50 = {
      policy_type               = "TargetTrackingScaling"
      estimated_instance_warmup = 1200
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 50.0
      }
    }
  }
}

```

### Variable Used ###


| Variable                                | Description                                                                                                     | Type        | Default     |
|-----------------------------------------|-----------------------------------------------------------------------------------------------------------------|-------------|-------------|
| create                                  | Determines whether to create autoscaling group or not                                                         | bool        | true        |
| ignore_desired_capacity_changes         | Determines whether the `desired_capacity` value is ignored after initial apply. See README note for more details | bool        | false       |
| name                                    | Name used across the resources created                                                                         | string      |             |
| use_name_prefix                         | Determines whether to use `name` as is or create a unique name beginning with the `name` as the prefix         | bool        | true        |
| instance_name                           | Name that is propagated to launched EC2 instances via a tag - if not provided, defaults to `var.name`          | string      | ""          |
| launch_template_id                      | ID of an existing launch template to be used (created outside of this module)                                  | string      | null        |
| launch_template_version                 | Launch template version. Can be version number, `$Latest`, or `$Default`                                       | string      | null        |
| availability_zones                      | A list of one or more availability zones for the group. Used for EC2-Classic and default subnets when not specified with `vpc_zone_identifier` argument. Conflicts with `vpc_zone_identifier` | list(string) | null        |
| vpc_zone_identifier                     | A list of subnet IDs to launch resources in. Subnets automatically determine which availability zones the group will reside. Conflicts with `availability_zones` | list(string) | null        |
| min_size                                | The minimum size of the autoscaling group                                                                      | number      | null        |
| max_size                                | The maximum size of the autoscaling group                                                                      | number      | null        |
| desired_capacity                        | The number of Amazon EC2 instances that should be running in the autoscaling group                            | number      | null        |
| desired_capacity_type                   | The unit of measurement for the value specified for desired_capacity. Supported for attribute-based instance type selection only. Valid values: `units`, `vcpu`, `memory-mib`. | string      | null        |
| capacity_rebalance                      | Indicates whether capacity rebalance is enabled                                                                | bool        | null        |
| min_elb_capacity                        | Setting this causes Terraform to wait for this number of instances to show up healthy in the ELB only on creation. Updates will not wait on ELB instance number changes | number      | null        |
| wait_for_elb_capacity                   | Setting this will cause Terraform to wait for exactly this number of healthy instances in all attached load balancers on both create and update operations. Takes precedence over `min_elb_capacity` behavior. | number      | null        |
| wait_for_capacity_timeout               | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. (See also Waiting for Capacity below.) Setting this to '0' causes Terraform to skip all Capacity Waiting behavior. | string      | null        |
| default_cooldown                        | The amount of time, in seconds, after a scaling activity completes before another scaling activity can start   | number      | null        |
| default_instance_warmup                 | Amount of time, in seconds, until a newly launched instance can contribute to the Amazon CloudWatch metrics. This delay lets an instance finish initializing before Amazon EC2 Auto Scaling aggregates instance metrics, resulting in more reliable usage data. Set this value equal to the amount of time that it takes for resource consumption to become stable after an instance reaches the InService state. | number      | null        |
| protect_from_scale_in                   | Allows setting instance protection. The autoscaling group will not select instances with this setting for termination during scale in events. | bool        | false       |
| load_balancers                          | A list of elastic load balancer names to add to the autoscaling group names. Only valid for classic load balancers. For ALBs, use `target_group_arns` instead | list(string) | []          |
| target_group_arns                       | A set of `aws_alb_target_group` ARNs, for use with Application or Network Load Balancing                      | list(string) | []          |
| placement_group                         | The name of the placement group into which you'll launch your instances, if any                                 | string      | null        |
| health_check_type                       | `EC2` or `ELB`. Controls how health checking is done                                                           | string      | null        |
| health_check_grace_period               | Time (in seconds) after instance comes into service before checking health                                      | number      | null        |
| force_delete                            | Allows deleting the Auto Scaling Group without waiting for all instances in the pool to terminate. You can force an Auto Scaling Group to delete even if it's in the process of scaling a resource. Normally, Terraform drains all the instances before deleting the group. This bypasses that behavior and potentially leaves resources dangling | bool        | null        |
| termination_policies                    | A list of policies to decide how the instances in the Auto Scaling Group should be terminated. The allowed values are `OldestInstance`, `NewestInstance`, `OldestLaunchConfiguration`, `ClosestToNextInstanceHour`, `OldestLaunchTemplate`, `AllocationStrategy`, `Default` | list(string) | []          |
| suspended_processes                     | A list of processes to suspend for the Auto Scaling Group. The allowed values are `Launch`, `Terminate`, `HealthCheck`, `ReplaceUnhealthy`, `AZRebalance`, `AlarmNotification`, `ScheduledActions`, `AddToLoadBalancer`, `InstanceRefresh`. Note that if you suspend either the `Launch` or `Terminate` process types, it can prevent your Auto Scaling Group from functioning properly | list(string) | []          |
| max_instance_lifetime                   | The maximum amount of time, in seconds, that an instance can be in service, values must be either equal to 0 or between 86400 and 31536000 seconds | number      | null        |
| enabled_metrics                         | A list of metrics to collect. The allowed values are `GroupDesiredCapacity`, `GroupInServiceCapacity`, `GroupPendingCapacity`, `GroupMinSize`, `GroupMaxSize`, `GroupInServiceInstances`, `GroupPendingInstances`, `GroupStandbyInstances`, `GroupStandbyCapacity`, `GroupTerminatingCapacity`, `GroupTerminatingInstances`, `GroupTotalCapacity`, `GroupTotalInstances` | list(string) | []          |
| metrics_granularity                     | The granularity to associate with the metrics to collect. The only valid value is `1Minute`                      | string      | null        |
| service_linked_role_arn                 | The ARN of the service-linked role that the ASG will use to call other AWS services                            | string      | null        |
| initial_lifecycle_hooks                 | One or more Lifecycle Hooks to attach to the Auto Scaling Group before instances are launched. The syntax is exactly the same as the separate `aws_autoscaling_lifecycle_hook` resource, without the `autoscaling_group_name` attribute. Please note that this will only work when creating a new Auto Scaling Group. For all other use-cases, please use `aws_autoscaling_lifecycle_hook` resource | list(map(string)) | []          |
| instance_refresh                        | If this block is configured, start an Instance Refresh when this Auto Scaling Group is updated                  | any         | {}          |
| use_mixed_instances_policy              | Determines whether to use a mixed instances policy in the autoscaling group or not                               | bool        | false       |
| mixed_instances_policy                  | Configuration block containing settings to define launch targets for Auto Scaling groups                        | any         | null        |
| delete_timeout                          | Delete timeout to wait for destroying autoscaling group                                                        | string      | null        |
| tags                                    | A map of tags to assign to resources                                                                            | map(string) | {}          |
| warm_pool                               | If this block is configured, add a Warm Pool to the specified Auto Scaling group                                | any         | {}          |
| ebs_optimized                           | If true, the launched EC2 instance will be EBS-optimized                                                         | bool        | null        |
| image_id                                | The AMI from which to launch the instance                                                                       | string      | ""          |
| instance_type                           | The type of the instance. If present then `instance_requirements` cannot be present                             | string      | null        |
| instance_requirements                   | The attribute requirements for the type of instance. If present then `instance_type` cannot be present           | any         | {}          |
| key_name                                | The key name that should be used for the instance                                                               | string      | null        |
| user_data                               | The Base64-encoded user data to provide when launching the instance                                             | string      | null        |
| security_groups                         | A list of security group IDs to associate                                                                       | list(string) | []          |
| enable_monitoring                       | Enables/disables detailed monitoring                                                                            | bool        | true        |
| metadata_options                        | Customize the metadata options for the instance                                                                 | map(string) | {}          |
| autoscaling_group_tags                  | A map of additional tags to add to the autoscaling group                                                        | map(string) | {}          |
| ignore_failed_scaling_activities        | Whether to ignore failed Auto Scaling scaling activities while waiting for capacity. The default is false -- failed scaling activities cause errors to be returned. | bool        | false       |
| instance_maintenance_policy             | If this block is configured, add an instance maintenance policy to the specified Auto Scaling group             | map(any)    | {}          |

| Variable                                | Description                                                                                                     | Type        | Default     |
|-----------------------------------------|-----------------------------------------------------------------------------------------------------------------|-------------|-------------|
| create_launch_template                  | Determines whether to create launch template or not                                                             | bool        | true        |
| launch_template_name                    | Name of launch template to be created                                                                           | string      | ""          |
| launch_template_use_name_prefix         | Determines whether to use `launch_template_name` as is or create a unique name beginning with the `launch_template_name` as the prefix | bool        | true        |
| launch_template_description             | Description of the launch template                                                                             | string      | null        |
| default_version                         | Default Version of the launch template                                                                         | string      | null        |
| update_default_version                  | Whether to update Default Version each update. Conflicts with `default_version`                                 | string      | null        |
| disable_api_termination                 | If true, enables EC2 instance termination protection                                                            | bool        | null        |
| disable_api_stop                        | If true, enables EC2 instance stop protection                                                                   | bool        | null        |
| instance_initiated_shutdown_behavior    | Shutdown behavior for the instance. Can be `stop` or `terminate`. (Default: `stop`)                             | string      | null        |
| kernel_id                               | The kernel ID                                                                                                   | string      | null        |
| ram_disk_id                             | The ID of the ram disk                                                                                          | string      | null        |
| block_device_mappings                   | Specify volumes to attach to the instance besides the volumes specified by the AMI                              | list(any)   | []          |
| capacity_reservation_specification      | Targeting for EC2 capacity reservations                                                                         | any         | {}          |
| cpu_options                             | The CPU options for the instance                                                                                | map(string) | {}          |
| credit_specification                    | Customize the credit specification of the instance                                                              | map(string) | {}          |
| elastic_gpu_specifications              | The elastic GPU to attach to the instance                                                                       | map(string) | {}          |
| elastic_inference_accelerator           | Configuration block containing an Elastic Inference Accelerator to attach to the instance                        | map(string) | {}          |
| enclave_options                         | Enable Nitro Enclaves on launched instances                                                                     | map(string) | {}          |
| hibernation_options                     | The hibernation options for the instance                                                                        | map(string) | {}          |
| instance_market_options                 | The market (purchasing) option for the instance                                                                 | any         | {}          |
| license_specifications                  | A list of license specifications to associate with                                                             | map(string) | {}          |
| maintenance_options                     | The maintenance options for the instance                                                                        | any         | {}          |
| network_interfaces                      | Customize network interfaces to be attached at instance boot time                                                | list(any)   | []          |
| placement                               | The placement of the instance                                                                                   | map(string) | {}          |
| private_dns_name_options                | The options for the instance hostname. The default values are inherited from the subnet                          | map(string) | {}          |
| tag_specifications                      | The tags to apply to the resources during launch                                                               | list(any)   | []          |

| Variable                                | Description                                                                                                     | Type        | Default     |
|-----------------------------------------|-----------------------------------------------------------------------------------------------------------------|-------------|-------------|
| create_traffic_source_attachment        | Determines whether to create autoscaling group traffic source attachment                                        | bool        | false       |
| traffic_source_identifier               | Identifies the traffic source. For Application Load Balancers, Gateway Load Balancers, Network Load Balancers, and VPC Lattice, this will be the Amazon Resource Name (ARN) for a target group in this account and Region. For Classic Load Balancers, this will be the name of the Classic Load Balancer in this account and Region | string      | ""          |
| traffic_source_type                     | Provides additional context for the value of identifier. The following lists the valid values: `elb` if `identifier` is the name of a Classic Load Balancer. `elbv2` if `identifier` is the ARN of an Application Load Balancer, Gateway Load Balancer, or Network Load Balancer target group. `vpc-lattice` if `identifier` is the ARN of a VPC Lattice target group | string      | "elbv2"     |

| Variable                                | Description                                                                                                     | Type        | Default     |
|-----------------------------------------|-----------------------------------------------------------------------------------------------------------------|-------------|-------------|
| create_schedule                         | Determines whether to create autoscaling group schedule or not                                                 | bool        | true        |
| schedules                               | Map of autoscaling group schedule to create                                                                     | map(any)    | {}          |

| Variable                                | Description                                                                                                     | Type        | Default     |
|-----------------------------------------|-----------------------------------------------------------------------------------------------------------------|-------------|-------------|
| create_scaling_policy                   | Determines whether to create target scaling policy schedule or not                                              | bool        | true        |
| scaling_policies                        | Map of target scaling policy schedule to create                                                                 | any         | {}          |

| Variable                                | Description                                                                                                     | Type        | Default     |
|-----------------------------------------|-----------------------------------------------------------------------------------------------------------------|-------------|-------------|
| create_iam_instance_profile             | Determines whether an IAM instance profile is created or to use an existing IAM instance profile                 | bool        | false       |
| iam_instance_profile_arn                | Amazon Resource Name (ARN) of an existing IAM instance profile. Used when `create_iam_instance_profile` = `false` | string      | null        |
| iam_instance_profile_name               | The name of the IAM instance profile to be created (`create_iam_instance_profile` = `true`) or existing (`create_iam_instance_profile` = `false`) | string      | null        |
| iam_role_name                           | Name to use on IAM role created                                                                                 | string      | null        |
| iam_role_use_name_prefix                | Determines whether the IAM role name (`iam_role_name`) is used as a prefix                                      | bool        | true        |
| iam_role_path                           | IAM role path                                                                                                   | string      | null        |
| iam_role_description                    | Description of the role                                                                                         | string      | null        |
| iam_role_permissions_boundary           | ARN of the policy that is used to set the permissions boundary for the IAM role                                 | string      | null        |
| iam_role_policies                       | IAM policies to attach to the IAM role                                                                          | map(string) | {}          |
| iam_role_tags                           | A map of additional tags to add to the IAM role created                                                         | map(string) | {}          |


*** Test Cases ***

| Module           | Test Cases                     | Result   | State Status                                        | Comments                                      |
|------------------|--------------------------------|----------|-----------------------------------------------------|-----------------------------------------------|
| Auto-Scaling     | Create Launch Configuration   | Success  | Create                                              |                                                 |
|                  | Update Launch Configuration   | Success  | Update in Place                                     |                                                 |
|                  | Delete Launch Configuration   | Success  | Destroy                                             | Will Destroy resource associate with Launch Configuration i.e. ASG |
|                  | Create ASG                    | Success  | Create                                              |                                                 |
|                  | Update ASG                    | Success  | Update in Place                                     |                                                 |
|                  | Delete ASG                    | Success  | Destroy                                             |                                                 |
|                  | Create Scaling Policy         | Success  | Create                                              |                                                 |
|                  | Update Scaling Policy         | Success  | Update in Place                                     |                                                 |
|                  | Delete Scaling Policy         | Success  | Destroy                                             |                                                 |
|                  | Create Instance Refresh       | Success  | Update in Place                                     |                                                 |
|                  | Create Tags                   | Success  | Create                                              |                                                 |
|                  | Update Tags                   | Success  | Update in Place                                     |                                                 |
|                  | Delete Tags                   | Success  | Update in Place                                     |                                                 |
