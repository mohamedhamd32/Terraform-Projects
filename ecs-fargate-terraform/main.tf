locals {
  name = "${var.project}-${var.environment}"
}

module "networking" {
  source = "./modules/networking"

  name     = local.name
  vpc_cidr = var.vpc_cidr
}

module "ecr" {
  source = "./modules/ecr"

  name = var.project
}

module "alb" {
  source = "./modules/alb"

  name                = local.name
  vpc_id              = module.networking.vpc_id
  subnet_ids          = module.networking.public_subnet_ids
  target_port         = var.container_port
  allowed_cidr_blocks = var.allowed_cidr_blocks
}

module "ecs" {
  source = "./modules/ecs"

  name                  = local.name
  vpc_id                = module.networking.vpc_id
  subnet_ids            = module.networking.public_subnet_ids
  alb_security_group_id = module.alb.security_group_id
  target_group_arn      = module.alb.target_group_arn

  image          = "${module.ecr.repository_url}:${var.image_tag}"
  container_port = var.container_port
  cpu            = var.task_cpu
  memory         = var.task_memory

  environment = {
    APP_VERSION = var.image_tag
  }

  desired_count = var.desired_count
  min_capacity  = var.min_capacity
  max_capacity  = var.max_capacity

  # Wait for the whole load balancer (including its listener) before creating the service.
  depends_on = [module.alb]
}
