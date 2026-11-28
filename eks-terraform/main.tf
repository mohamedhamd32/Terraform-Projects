############################################
# Root module: wires the vpc, iam and eks modules together
############################################

# 1. Network: VPC, public/private subnets, Internet Gateway, NAT gateway
module "vpc" {
  source = "./modules/vpc"

  name         = var.cluster_name
  cluster_name = var.cluster_name
  vpc_cidr     = var.vpc_cidr
  az_count     = var.az_count
}

# 2. IAM: cluster role and node role
module "iam" {
  source = "./modules/iam"

  name_prefix = var.cluster_name
}

# 3. EKS: cluster, add-ons, node group, access entries
module "eks" {
  source = "./modules/eks"

  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  cluster_role_arn   = module.iam.cluster_role_arn

  # Control-plane ENIs can use all subnets; nodes go in private subnets only
  cluster_subnet_ids           = concat(module.vpc.public_subnet_ids, module.vpc.private_subnet_ids)
  endpoint_public_access_cidrs = var.endpoint_public_access_cidrs

  node_role_arn       = module.iam.node_role_arn
  node_subnet_ids     = module.vpc.private_subnet_ids
  node_instance_types = var.node_instance_types
  node_capacity_type  = var.node_capacity_type
  node_ami_type       = var.node_ami_type
  node_disk_size      = var.node_disk_size
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size

  access_entries = var.access_entries
}
