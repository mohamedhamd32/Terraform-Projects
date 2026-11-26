locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

module "network" {
  source = "./modules/network"

  name_prefix        = local.name_prefix
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
}

module "security" {
  source = "./modules/security"

  name_prefix = local.name_prefix
  vpc_id      = module.network.vpc_id
}

module "compute" {
  source = "./modules/compute"

  name_prefix           = local.name_prefix
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  private_subnet_ids    = module.network.private_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  ec2_security_group_id = module.security.ec2_security_group_id

  instance_type      = var.instance_type
  ami_id             = var.ami_id
  min_size           = var.min_size
  max_size           = var.max_size
  desired_capacity   = var.desired_capacity
  notification_email = var.notification_email
}
