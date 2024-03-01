# Security group
resource "aws_security_group" "application_sg" {
  vpc_id      = aws_vpc.cc4_vpc.id
  description = "Allow ssh and 8080 inbound traffic (from presentation tier) and all outbound traffic"

  tags = {
    Name = "Application Tier Security Group"
  }
}

# Inbound rules
resource "aws_vpc_security_group_ingress_rule" "application_inbound_ssh" {
  security_group_id            = aws_security_group.application_sg.id
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.presentation_sg.id
  from_port                    = 22
  to_port                      = 22
}

resource "aws_vpc_security_group_ingress_rule" "application_inbound_8080" {
  security_group_id            = aws_security_group.application_sg.id
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.presentation_sg.id
  from_port                    = 8080
  to_port                      = 8080
}

# Outbound rules
resource "aws_vpc_security_group_egress_rule" "application_outbound_all" {
  security_group_id = aws_security_group.application_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Route table
resource "aws_route_table" "application_rt_private" {
  vpc_id = aws_vpc.cc4_vpc.id

  tags = {
    Name = "Private Route Table (Application)"
  }
}

resource "aws_route_table_association" "applicatin_rt_association_az" {
  count = 2

  subnet_id      = aws_subnet.application_subnet[count.index].id
  route_table_id = aws_route_table.application_rt_private.id
}
