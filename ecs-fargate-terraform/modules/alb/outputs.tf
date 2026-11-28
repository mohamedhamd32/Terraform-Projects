output "dns_name" {
  description = "Public DNS name of the load balancer."
  value       = aws_lb.this.dns_name
}

output "security_group_id" {
  description = "Security group attached to the load balancer. Tasks allow inbound traffic from this group only."
  value       = aws_security_group.alb.id
}

output "target_group_arn" {
  description = "ARN of the target group the ECS service registers tasks into."
  value       = aws_lb_target_group.this.arn
}
