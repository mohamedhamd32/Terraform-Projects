variable "aws_region" {
  description = "AWS region in which to create the autoscaling lab."
  type        = string
  default     = "eu-north-1"
}

variable "ami_id" {
  description = "Ubuntu 22.04 x86_64 AMI ID for aws_region."
  type        = string
  default     = "ami-09d835910a77f135c"
}

variable "availability_zones" {
  description = "Exactly three Availability Zone names available in aws_region."
  type        = list(string)
  default     = ["eu-north-1a","eu-north-1b","eu-north-1c"]

  validation {
    condition     = length(var.availability_zones) == 3 && length(distinct(var.availability_zones)) == 3
    error_message = "Provide exactly three distinct Availability Zone names in aws_region."
  }
}

variable "project_name" {
  description = "Short prefix used to name the lab resources."
  type        = string
  default     = "cw-asg"
}

variable "environment" {
  description = "Environment name used in resource names."
  type        = string
  default     = "lab"
}

variable "vpc_cidr" {
  description = "IPv4 CIDR range for the lab VPC; must have room for six /24 subnets."
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "EC2 instance type used by the Auto Scaling launch template."
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Minimum number of EC2 instances maintained by the Auto Scaling Group."
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of EC2 instances allowed in the Auto Scaling Group."
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Initial number of EC2 instances to launch."
  type        = number
  default     = 1
}

variable "notification_email" {
  description = "Optional email address for CloudWatch alarm notifications; leave empty to disable the subscription."
  type        = string
  default     = "mohanj399@gmail.com"
}
