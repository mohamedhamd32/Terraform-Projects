output "alb_security_group_id" {
  description = "Security group ID attached to the public Application Load Balancer."
  value       = aws_security_group.alb.id
}

output "ec2_security_group_id" {
  description = "Security group ID attached to the private Auto Scaling instances."
  value       = aws_security_group.ec2.id
}
