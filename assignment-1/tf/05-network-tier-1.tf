# Security group
resource "aws_security_group" "presentation_sg" {
  vpc_id      = aws_vpc.cc4_vpc.id
  description = "Allow http/https/ssh inbound traffic and all outbound traffic"

  tags = {
    Name = "Presentation Tier Security Group"
  }
}

# Inbound rules
resource "aws_vpc_security_group_ingress_rule" "presentation_inbound_http" {
  security_group_id = aws_security_group.presentation_sg.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80

  # update this line when presentation load balancer is setup
  # referenced_security_group_id = aws_security_group.presentation_lb_sg.id
  cidr_ipv4 = "0.0.0.0/0"
}

# Outbound rules
resource "aws_vpc_security_group_egress_rule" "presentation_outbound_all" {
  security_group_id = aws_security_group.presentation_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Internet gateway
resource "aws_internet_gateway" "cc4_igw" {
  vpc_id = aws_vpc.cc4_vpc.id

  tags = {
    Name = "CC4 Internet Gateway"
  }
}

# Route table
resource "aws_route_table" "presentation_rt_public" {
  vpc_id = aws_vpc.cc4_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cc4_igw.id
  }

  tags = {
    Name = "Public Route Table (Presentation)"
  }
}

resource "aws_route_table_association" "presentation_rt_association_az" {
  count = 2

  subnet_id      = aws_subnet.presentation_subnet[count.index].id
  route_table_id = aws_route_table.presentation_rt_public.id

}
