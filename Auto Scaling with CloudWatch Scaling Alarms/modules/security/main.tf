## Security groups for the application load balancer and web server instances.
## This module defines the security groups for the application load balancer (ALB) and the web server EC2 instances.
## It creates an ALB security group allowing HTTP/HTTPS traffic from the internet and a web server security group allowing traffic only from the ALB and outbound access through the NAT gateway.

locals {
  name_prefix = var.name_prefix
}

# Allows public HTTP/HTTPS requests to reach the load balancer and allows its responses out.
resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Internet-facing HTTP and HTTPS access to the application load balancer."
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP web requests."
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS web requests."
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Forward application traffic to registered targets."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-alb-sg"
  }
}

# Restricts web-server ingress to the load balancer and permits outbound package downloads through NAT.
resource "aws_security_group" "ec2" {
  name        = "${local.name_prefix}-ec2-sg"
  description = "Web server access restricted to the load balancer."
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP health checks and web requests from the load balancer for the web server ingress security group"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Outbound access for OS package installation and updates for nat gateway traffic for the web server egress security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name_prefix}-ec2-sg"
  }
}
