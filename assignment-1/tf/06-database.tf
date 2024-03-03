# In case we go for multi AZ we need the subnet group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "rds_subnet_group"
  subnet_ids = [
    aws_subnet.data_subnet[0].id,
    aws_subnet.data_subnet[1].id,
  ]

  tags = {
    Name = "Subnet group for RDS multi AZ"
  }
}

# Create the rds instance
resource "aws_db_instance" "db_instance" {
  engine                 = "mysql"
  engine_version         = "8.0.35"
  multi_az               = true
  identifier             = "cc4-rds-instance"
  db_name                = "cc4_db"
  username               = "root"
  password               = "toortoor"
  instance_class         = "db.t2.micro"
  allocated_storage      = 20
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.data_sg.id]
  skip_final_snapshot    = true
  apply_immediately      = true
}

# output "db_instance_endpoint" {
#   description = "The connection endpoint for the DB instance"
#   value       = aws_db_instance.db_instance.endpoint
# }
