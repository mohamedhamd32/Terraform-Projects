############################################
# Cluster
############################################

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the control plane."
  type        = string
}

variable "cluster_role_arn" {
  description = "ARN of the cluster IAM role."
  type        = string
}

variable "cluster_subnet_ids" {
  description = "Subnets where EKS places control-plane ENIs (at least 2, in different AZs)."
  type        = list(string)
}

variable "endpoint_public_access_cidrs" {
  description = "CIDRs allowed to reach the public API endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

############################################
# Node group
############################################

variable "node_role_arn" {
  description = "ARN of the worker node IAM role."
  type        = string
}

variable "node_subnet_ids" {
  description = "Subnets for worker nodes (private subnets)."
  type        = list(string)
}

variable "node_instance_types" {
  description = "EC2 instance types for worker nodes."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_capacity_type" {
  description = "ON_DEMAND or SPOT."
  type        = string
  default     = "ON_DEMAND"
}

variable "node_ami_type" {
  description = "AMI type for worker nodes."
  type        = string
  default     = "AL2023_x86_64_STANDARD"
}

variable "node_disk_size" {
  description = "Root volume size (GiB) per node."
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
# Access entries
############################################

variable "access_entries" {
  description = "Extra IAM principals to grant cluster access (principal_arn, policy_arn, optional namespaces)."
  type = map(object({
    principal_arn = string
    policy_arn    = string
    namespaces    = optional(list(string), [])
  }))
  default = {}
}
