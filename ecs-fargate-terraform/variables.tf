variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "eu-central-1"
}

variable "project" {
  description = "Project name. Used as a prefix for resource names, so keep it short, lowercase and free of spaces."
  type        = string
  default     = "demo-api"
}

variable "environment" {
  description = "Environment name, for example dev or staging."
  type        = string
  default     = "dev"
}

variable "image_tag" {
  description = "Tag of the container image in ECR to deploy. Change it to roll out a new version."
  type        = string
  default     = "v1"
}

variable "container_port" {
  description = "Port the application listens on."
  type        = number
  default     = 8080
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to reach the load balancer. Restrict this to your own IP for private experiments."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "task_cpu" {
  description = "Fargate task CPU units (256 = 0.25 vCPU)."
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Fargate task memory in MB."
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Initial number of running tasks."
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "Minimum number of tasks when auto scaling."
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum number of tasks when auto scaling."
  type        = number
  default     = 6
}
