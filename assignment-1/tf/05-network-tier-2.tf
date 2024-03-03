# Security group
resource "aws_security_group" "application_sg" {
  vpc_id      = aws_vpc.cc4_vpc.id
  description = "Allow ssh and 8080 inbound traffic (from presentation tier) and all outbound traffic"

  tags = {
    Name = "Application Tier Security Group"
  }
}

# Inbound rules
resource "aws_vpc_security_group_ingress_rule" "application_inbound_8080" {
  security_group_id = aws_security_group.application_sg.id
  ip_protocol       = "tcp"
  from_port         = 8080
  to_port           = 8080

  # update this line when applicatin load balancer ios setup
  # referenced_security_group_id = aws_security_group.application_lb_sg.id
  referenced_security_group_id = aws_security_group.presentation_sg.id
}

# Outbound rules
resource "aws_vpc_security_group_egress_rule" "application_outbound_all" {
  security_group_id = aws_security_group.application_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# NAT gateway
resource "aws_nat_gateway" "cc4_nat" {
  count = 2

  allocation_id = aws_eip.ccf_private_eip[count.index].id
  subnet_id     = aws_subnet.presentation_subnet[count.index].id

  tags = {
    Name = "NAT Gateway ${count.index + 1} (Application)"
  }

  depends_on = [aws_internet_gateway.cc4_igw]
}

# Elastic IPs for NAT gateways
resource "aws_eip" "ccf_private_eip" {
  count = 2

  domain = "vpc"
}

# Route table
resource "aws_route_table" "application_rt_private" {
  count = 2

  vpc_id = aws_vpc.cc4_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.cc4_nat[count.index].id
  }

  tags = {
    Name = "Private Route Table ${count.index + 1} (Application)"
  }
}

resource "aws_route_table_association" "applicatin_rt_association_az" {
  count = 2

  subnet_id      = aws_subnet.application_subnet[count.index].id
  route_table_id = aws_route_table.application_rt_private[count.index].id
}
