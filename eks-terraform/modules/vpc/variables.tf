variable "name" {
  description = "Name prefix for VPC resources."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name, used in the kubernetes.io/cluster/<name> subnet tag."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC. Subnet math assumes a /16."
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of Availability Zones (one public + one private subnet per AZ)."
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 3
    error_message = "az_count must be 2 or 3 (EKS needs at least 2 AZs)."
  }
}
