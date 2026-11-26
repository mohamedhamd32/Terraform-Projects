output "application_url" {
  description = "HTTP URL of the internet-facing Application Load Balancer."
  value       = "http://${module.compute.load_balancer_dns_name}"
}

output "autoscaling_group_name" {
  description = "Name of the EC2 Auto Scaling Group."
  value       = module.compute.autoscaling_group_name
}

output "vpc_id" {
  description = "ID of the VPC created for the lab."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the three public subnets used by the load balancer."
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the three private subnets used by EC2 instances."
  value       = module.network.private_subnet_ids
}

output "scale_out_alarm_name" {
  description = "CloudWatch alarm that adds an instance at high average CPU utilization."
  value       = module.compute.scale_out_alarm_name
}

output "scale_in_alarm_name" {
  description = "CloudWatch alarm that removes an instance at low average CPU utilization."
  value       = module.compute.scale_in_alarm_name
}

output "alarm_notification_topic_arn" {
  description = "SNS topic ARN used for alarm notifications."
  value       = module.compute.notification_topic_arn
}
