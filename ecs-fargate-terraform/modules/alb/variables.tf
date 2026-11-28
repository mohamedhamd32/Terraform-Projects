variable "name" {
  description = "Name prefix for the load balancer resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC in which to create the load balancer and target group."
  type        = string
}

variable "subnet_ids" {
  description = "Public subnets (in at least two AZs) for the load balancer."
  type        = list(string)
}

variable "target_port" {
  description = "Port on which the containers listen."
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "HTTP path the load balancer uses to check task health."
  type        = string
  default     = "/health"
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to reach the load balancer on port 80."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
