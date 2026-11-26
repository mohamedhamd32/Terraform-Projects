variable "name_prefix" {
  description = "Prefix used to name security resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the application security groups will be created."
  type        = string
}
