output "app_url" {
  description = "URL of the application (served through the load balancer)."
  value       = "http://${module.alb.dns_name}"
}

output "ecr_repository_url" {
  description = "ECR repository URL. Push your container images here."
  value       = module.ecr.repository_url
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service."
  value       = module.ecs.service_name
}

output "log_group_name" {
  description = "CloudWatch log group with the container logs."
  value       = module.ecs.log_group_name
}
