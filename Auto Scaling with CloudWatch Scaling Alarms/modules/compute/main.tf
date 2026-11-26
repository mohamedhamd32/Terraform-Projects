# Groups the web application resources and provides a target for the load balancer.
resource "aws_lb" "this" {
  name               = "${var.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "${var.name_prefix}-alb"
  }
}

# Defines the EC2 web-server port, protocol, and health check used by the load balancer.
resource "aws_lb_target_group" "web" {
  name        = "${var.name_prefix}-web"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.name_prefix}-web"
  }
}

# Listens for public HTTP requests and forwards them to healthy EC2 targets.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# Defines the EC2 AMI, instance size, security group, and Nginx bootstrap script for Auto Scaling Group service .
resource "aws_launch_template" "web" {
  name_prefix            = "${var.name_prefix}-web-"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.ec2_security_group_id]
  user_data              = filebase64("${path.module}/user_data.sh")

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.name_prefix}-web"
    }
  }
}

# Maintains a bounded fleet of private EC2 instances and registers them with the ALB target group.
resource "aws_autoscaling_group" "web" {
  name                      = "${var.name_prefix}-web-asg"
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity // 
  vpc_zone_identifier       = var.private_subnet_ids
  target_group_arns         = [aws_lb_target_group.web.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300
  default_instance_warmup   = 120

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-web"
    propagate_at_launch = true
  }

  # Scaling alarms manage live capacity; Terraform should not reset it on later applies.
  lifecycle {
    ignore_changes = [desired_capacity]
  }

  depends_on = [aws_lb_listener.http]
}

# Adds one EC2 instance when the high-CPU CloudWatch alarm enters ALARM.
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.name_prefix}-scale-out"
  autoscaling_group_name = aws_autoscaling_group.web.name
  policy_type            = "SimpleScaling" // simple scaling policy: adds or removes a fixed number of instances
  adjustment_type        = "ChangeInCapacity" // changes the number of instances by the specified scaling adjustment how ?
  // in this case, scaling_adjustment = 1 means add one instance, scaling_adjustment = -1 means remove one instance
  scaling_adjustment     = 1
  cooldown               = 300
}

# Removes one EC2 instance when the low-CPU CloudWatch alarm enters ALARM.
resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.name_prefix}-scale-in"
  autoscaling_group_name = aws_autoscaling_group.web.name
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}


//// SNS Notifications for Auto Scaling Group CPU Utilization.//////
# Creates the SNS destination used to notify subscribers when either CPU alarm fires.
resource "aws_sns_topic" "alarms" {
  name = "${var.name_prefix}-cpu-alarms"
}

# Subscribes the configured email address; the recipient must confirm the SNS subscription.
resource "aws_sns_topic_subscription" "email" {
  count     = var.notification_email == "" ? 0 : 1
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# Scales out and sends a notification when average ASG CPU is at least 70% for two periods.
resource "aws_cloudwatch_metric_alarm" "scale_out" {
  alarm_name          = "${var.name_prefix}-cpu-high"
  alarm_description   = "Scale out when average Auto Scaling Group CPU utilization is at least 70% for two periods."
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  treat_missing_data  = "notBreaching"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }

  alarm_actions = [
    aws_autoscaling_policy.scale_out.arn,
    aws_sns_topic.alarms.arn,
  ]
}

# Scales in and sends a notification when average ASG CPU is at most 40% for two periods.
resource "aws_cloudwatch_metric_alarm" "scale_in" {
  alarm_name          = "${var.name_prefix}-cpu-low"
  alarm_description   = "Scale in when average Auto Scaling Group CPU utilization is at most 40% for two periods."
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 40
  treat_missing_data  = "notBreaching"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }

  alarm_actions = [
    aws_autoscaling_policy.scale_in.arn,
    aws_sns_topic.alarms.arn,
  ]
}
