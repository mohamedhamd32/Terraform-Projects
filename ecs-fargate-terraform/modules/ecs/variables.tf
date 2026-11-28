variable "name" {
  description = "Name prefix for the cluster, service, task definition and container."
  type        = string
}

variable "vpc_id" {
  description = "VPC in which the tasks run."
  type        = string
}

variable "subnet_ids" {
  description = "Subnets in which tasks are placed (use at least two for availability)."
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group of the load balancer. The task security group only accepts traffic from it."
  type        = string
}

variable "target_group_arn" {
  description = "ARN of the load balancer target group that tasks register into."
  type        = string
}

variable "image" {
  description = "Full container image URI including tag, for example 123456789012.dkr.ecr.eu-central-1.amazonaws.com/demo-api:v1."
  type        = string
}

variable "container_port" {
  description = "Port the container listens on."
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "HTTP path used by the container-level health check."
  type        = string
  default     = "/health"
}

variable "environment" {
  description = "Environment variables passed to the container."
  type        = map(string)
  default     = {}
}

variable "cpu" {
  description = "Task CPU units. Must be a valid Fargate combination with memory (256 CPU supports 512 to 2048 MB)."
  type        = number
  default     = 256
}

variable "memory" {
  description = "Task memory in MB."
  type        = number
  default     = 512
}

variable "cpu_architecture" {
  description = "CPU architecture of the image: X86_64 or ARM64."
  type        = string
  default     = "X86_64"

  validation {
    condition     = contains(["X86_64", "ARM64"], var.cpu_architecture)
    error_message = "cpu_architecture must be X86_64 or ARM64."
  }
}

variable "desired_count" {
  description = "Initial number of tasks. Auto scaling manages the count afterwards."
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "Minimum number of tasks for auto scaling."
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum number of tasks for auto scaling."
  type        = number
  default     = 6
}

variable "cpu_target_percent" {
  description = "Average CPU utilisation that auto scaling tries to maintain."
  type        = number
  default     = 50
}

variable "assign_public_ip" {
  description = "Give tasks a public IP. Required in public subnets without NAT so tasks can pull from ECR."
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "How long CloudWatch keeps container logs."
  type        = number
  default     = 7
}
