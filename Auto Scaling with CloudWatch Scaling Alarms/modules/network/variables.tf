variable "name_prefix" {
  description = "Prefix used to name network resources."
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR range for the VPC; six /24 subnet ranges are derived from it."
  type        = string
}

variable "availability_zones" {
  description = "Exactly three Availability Zone names in the configured AWS region."
  type        = list(string)
}
