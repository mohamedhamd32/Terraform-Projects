output "load_balancer_dns_name" {
  description = "DNS name of the public Application Load Balancer."
  value       = aws_lb.this.dns_name
}

output "autoscaling_group_name" {
  description = "Name of the EC2 Auto Scaling Group."
  value       = aws_autoscaling_group.web.name
}

output "scale_out_alarm_name" {
  description = "Name of the high CPU alarm."
  value       = aws_cloudwatch_metric_alarm.scale_out.alarm_name
}

output "scale_in_alarm_name" {
  description = "Name of the low CPU alarm."
  value       = aws_cloudwatch_metric_alarm.scale_in.alarm_name
}

output "notification_topic_arn" {
  description = "ARN of the SNS topic that alarm actions publish notifications to."
  value       = aws_sns_topic.alarms.arn
}
