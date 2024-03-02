# Security group
resource "aws_security_group" "data_sg" {
  vpc_id      = aws_vpc.cc4_vpc.id
  description = "Allow ssh/mysql inbound traffic (from application tier) and all outbound traffic"

  tags = {
    Name = "Data Tier Security Group"
  }
}

# Inbound rules
resource "aws_vpc_security_group_ingress_rule" "data_inbound_ssh" {
  security_group_id            = aws_security_group.data_sg.id
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.application_sg.id
  from_port                    = 22
  to_port                      = 22
}

resource "aws_vpc_security_group_ingress_rule" "data_inbound_mysql" {
  security_group_id            = aws_security_group.data_sg.id
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.application_sg.id
  from_port                    = 3306
  to_port                      = 3306
}

# Outbound rules
resource "aws_vpc_security_group_egress_rule" "data_outbound_all" {
  security_group_id = aws_security_group.data_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Route table
resource "aws_route_table" "data_rt_private" {
  vpc_id = aws_vpc.cc4_vpc.id

  tags = {
    Name = "Private Route Table (Data)"
  }
}

resource "aws_route_table_association" "data_rt_association_az" {
  count = 2

  subnet_id      = aws_subnet.data_subnet[count.index].id
  route_table_id = aws_route_table.data_rt_private.id
}
