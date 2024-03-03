# Security group
resource "aws_security_group" "presentation_lb_sg" {
  vpc_id      = aws_vpc.cc4_vpc.id
  description = "Allow 80 inbound traffic and all outbound traffic"

  tags = {
    Name = "Presentation Tier Load Balancer Security Group"
  }
}

# Inbound rules
resource "aws_vpc_security_group_ingress_rule" "presentation_lb_inbound_80" {
  security_group_id = aws_security_group.presentation_lb_sg.id
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
}

# Outbound rules
resource "aws_vpc_security_group_egress_rule" "presentation_lb_outbound_all" {
  security_group_id = aws_security_group.presentation_lb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Target group
resource "aws_lb_target_group" "presentation_tg" {
  name        = "presentation-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.cc4_vpc.id
  health_check {
    path = "/"
    port = 80
  }

  tags = {
    Name = "Presentation Target Group"
  }
}

# Load balancer
resource "aws_lb" "presentation_lb" {
  name               = "presentation-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.presentation_lb_sg.id]
  subnets            = [for subnet in aws_subnet.presentation_subnet : subnet.id]

  drop_invalid_header_fields = true

  tags = {
    Name = "Presentation Load Balancer"
  }
}

resource "aws_lb_listener" "presentation_lb_listener" {
  load_balancer_arn = aws_lb.presentation_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.presentation_tg.arn
  }
}

# Launch template
resource "aws_launch_template" "presentation_lt" {
  name = "presentation_lt"

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 8
    }
  }

  image_id = var.presentation_ami

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = "t2.micro"

  monitoring {
    enabled = true
  }

  vpc_security_group_ids = [aws_security_group.presentation_sg.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "CC4 Presentation Instance"
    }
  }

  tags = {
    Name = "Application Launch Template"
  }
}

# Auto-scaling group
resource "aws_autoscaling_group" "presentation_asg" {
  name                = "presentation_asg"
  max_size            = 2
  min_size            = 1
  desired_capacity    = 2
  vpc_zone_identifier = [for subnet in aws_subnet.presentation_subnet : subnet.id]

  launch_template {
    id = aws_launch_template.presentation_lt.id
  }
}

# ALB Target Group attachment
resource "aws_autoscaling_attachment" "presentation_attachment" {
  autoscaling_group_name = aws_autoscaling_group.presentation_asg.id
  lb_target_group_arn    = aws_lb_target_group.presentation_tg.arn
}


output "laod_balancer_dns" {
  description = "The DNS for Load Balancer"
  value       = aws_lb.presentation_lb.dns_name
}
