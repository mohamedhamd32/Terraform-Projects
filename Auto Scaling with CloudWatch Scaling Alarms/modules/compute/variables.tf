variable "name_prefix" {
  description = "Prefix used to name compute resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID used by the load balancer target group."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the internet-facing load balancer."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs in which the Auto Scaling Group launches instances."
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID attached to the Application Load Balancer."
  type        = string
}

variable "ec2_security_group_id" {
  description = "Security group ID attached to the EC2 launch template."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type used by the launch template."
  type        = string
}

variable "ami_id" {
  description = "Ubuntu 22.04 x86_64 AMI ID to use for EC2 instances in the configured region."
  type        = string
}

variable "min_size" {
  description = "Minimum Auto Scaling Group size."
  type        = number
}

variable "max_size" {
  description = "Maximum Auto Scaling Group size."
  type        = number
}

variable "desired_capacity" {
  description = "Initial Auto Scaling Group capacity."
  type        = number
}

variable "notification_email" {
  description = "Optional email address to subscribe to the alarm notification topic."
  type        = string
}
