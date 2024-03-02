# Security group
resource "aws_security_group" "application_lb_sg" {
  vpc_id      = aws_vpc.cc4_vpc.id
  description = "Allow 8080 inbound traffic and all outbound traffic"

  tags = {
    Name = "Application Tier Load Balancer Security Group"
  }
}

# Inbound rules
resource "aws_vpc_security_group_ingress_rule" "application_lb_inbound_8080" {
  security_group_id            = aws_security_group.application_lb_sg.id
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.presentation_sg.id
  from_port                    = 8080
  to_port                      = 8080
}

# Outbound rules
resource "aws_vpc_security_group_egress_rule" "application_lb_outbound_all" {
  security_group_id = aws_security_group.application_lb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Target group
resource "aws_lb_target_group" "application_tg" {
  name        = "application-tg"
  target_type = "instance"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.cc4_vpc.id

  tags = {
    Name = "Application Traget Group"
  }
}

# Load balancer
resource "aws_lb" "application_lb" {
  name               = "application-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.application_lb_sg.id]
  subnets            = [for subnet in aws_subnet.application_subnet : subnet.id]

  drop_invalid_header_fields = true

  tags = {
    Name = "Application Load Balancer"
  }
}

resource "aws_lb_listener" "application_lb_listener" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.application_tg.arn
  }
}

# Launch template
resource "aws_launch_template" "application_lt" {
  name = "application_lt"

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 8
    }
  }

  image_id = var.application_ami

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = "t2.micro"

  monitoring {
    enabled = true
  }

  vpc_security_group_ids = [aws_security_group.application_sg.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "CC4 Application Instance"
    }
  }

  tags = {
    Name = "Application Launch Template"
  }
}

# Auto-scaling group
resource "aws_autoscaling_group" "appplication_asg" {
  name                = "application_asg"
  max_size            = 2
  min_size            = 1
  desired_capacity    = 2
  vpc_zone_identifier = [for subnet in aws_subnet.application_subnet : subnet.id]

  launch_template {
    id = aws_launch_template.application_lt.id
  }
}
