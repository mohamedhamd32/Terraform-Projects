############################################
# General
############################################

variable "region" {
  description = "AWS Region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster (also used as a prefix for other resources)."
  type        = string
  default     = "practice-eks"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the control plane. Check supported versions with: aws eks describe-cluster-versions"
  type        = string
  default     = "1.37"
}

variable "tags" {
  description = "Extra tags added to all resources."
  type        = map(string)
  default     = {}
}

############################################
# Networking
############################################

variable "vpc_cidr" {
  description = "CIDR block for the VPC. Subnet math assumes a /16."
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of Availability Zones (2 or 3)."
  type        = number
  default     = 2
}

variable "endpoint_public_access_cidrs" {
  description = "CIDRs allowed to reach the public Kubernetes API endpoint. Restrict to your own IP (x.x.x.x/32) for better security."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

############################################
# Worker nodes
############################################

variable "node_instance_types" {
  description = "EC2 instance types for worker nodes."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_capacity_type" {
  description = "ON_DEMAND or SPOT."
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "node_capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "node_ami_type" {
  description = "AMI type for worker nodes."
  type        = string
  default     = "AL2023_x86_64_STANDARD"
}

variable "node_disk_size" {
  description = "Root volume size (GiB) for each worker node."
  type        = number
  default     = 20
}

variable "node_desired_size" {
  description = "Number of worker nodes to run now."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 2
}

############################################
# Cluster access for other IAM users/roles
############################################

variable "access_entries" {
  description = <<-EOT
    Extra IAM principals to grant access to the cluster.
    The identity running Terraform is made cluster admin automatically.
    policy_arn examples:
      arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy
      arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy
      arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy
    Leave namespaces empty for cluster-wide scope.
  EOT
  type = map(object({
    principal_arn = string
    policy_arn    = string
    namespaces    = optional(list(string), [])
  }))
  default = {}
}
