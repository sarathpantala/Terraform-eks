variable "cluster_version" {
  type = "string"
}

variable "aws_region" {
  type = "string"
}

variable "aws_account" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "ami" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "subnets" {
  type = "string"
}

variable "environment_tag" {
  type = "string"
}

variable "service_tag" {
  type = "string"
}

variable "team_tag" {
  type = "string"
}

variable "route53_zone_id" {
  type = "string"
}


variable "worker_group_count" {
  type    = "string"
  default = "0"
}

variable "workers_group_launch_template_defaults" {
  type    = "map"
  default = {}
}

variable "worker_group_launch_template_count" {
  type = "string"
}

variable "worker_group_launch_template_tags" {
  type = "map"

  default = {
    default = []
  }
}

variable "worker_groups_launch_template" {
  type = "list"
}

variable "worker_additional_security_group_ids" {
  description = "A list of additional security group ids to attach to worker instances"
  type        = "string"
  default     = ""
}

variable "kubeconfig_aws_authenticator_command" {
  type = "string"
}

variable "kubeconfig_aws_authenticator_env_variables" {
  type    = "map"
  default = {}
}

variable "config_output_path" {
  type = "string"
}

variable "map_roles" {
  type = "list"
  default= []
}

variable "map_roles_count" {
  description = "The count of roles in the map_roles list."
  type        = "string"
  default     = 0
}

variable "map_users" {
  type = "list"
  default= []
}

variable "map_users_count" {
  description = "The count of users in the map_users list."
  type        = "string"
  default     = 0
}

variable "kubeconfig_aws_authenticator_additional_args" {
  description = "Any additional arguments to pass to the authenticator such as the role to assume. e.g. [\"-r\", \"MyEksRole\"]."
  type        = "list"
  default     = []
}

variable "mgmt_sg_ids" {
  description = "Security Group IDs for SSH access to worker nodes"
  type = "list"
  default= []
}

variable "egress_with_cidr_blocks" {
  description = "Worker node egress to cidr"
  default     = ["172.16.0.0/16"]
}

variable "egress_with_sg" {
  description = "Worker node egress to security group"
  default     = []
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = "string"
  default     = false
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled."
  type        = "string"
  default     = true
}

variable "web_kinesis_stream_arn" {
  description = "Web Kinesis Stream Arn"
  type        = "string"
  default     = "*"
}

variable "backup_logs_s3_bucket" {
  description = "Backup Logs Bucket Name"
  type        = "string"
  default     = ""
}

variable "image_processor_s3_bucket" {
  description = "Image Processor Bucket Name"
  type        = "string"
  default     = ""
}

variable "log_stream_list" {
  description = "list of kinesis streams for logs"
  type        = "list"
  default     = []
}

variable "log_stream_dynamodb_list" {
  description = "list of kinesis dynamodb for logs"
  type        = "list"
  default     = []
}

variable "sg_alb_mapp" {
  description = "sg_alb_mapp"
  default     = 0
}

variable "sg_alb_poshladder" {
  description = "sg_alb_poshladder"
  default     = 0
}

variable "sg_alb_poshci" {
  description = "sg_alb_poshci"
  default     = 0
}

variable "web_tg_binding" {
  description = "new target group for web"
  default = 0
}

variable "devteam_web_tg_binding" {
  description = "new target group for devteam web"
  default = 0
}

variable "devteam_mapp_tg_binding" {
  description = "new target group for devteam mapp"
  default = 0
}

variable "wallaby_web_tg_binding" {
  description = "new target group for wallaby web"
  default = 0
}

variable "wallaby_mapp_tg_binding" {
  description = "new target group for wallaby mapp"
  default = 0
}

variable "qaauto_web_tg_binding" {
  description = "new target group for qaauto web"
  default = 0
}

variable "qaauto_mapp_tg_binding" {
  description = "new target group for qaauto mapp"
  default = 0
}

variable "ut_web_tg_binding" {
  description = "new target group for ut web"
  default = 0
}
