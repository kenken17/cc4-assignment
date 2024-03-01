resource "aws_vpc" "cc4_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "CC4 VPC"
  }
}

resource "aws_subnet" "presentation_subnet" {
  count = 2

  vpc_id            = aws_vpc.cc4_vpc.id
  cidr_block        = var.presentation_subnet_cidr[count.index]
  availability_zone = var.subnet_az[count.index]

  tags = {
    Name = "Presentation Tier Subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "application_subnet" {
  count = 2

  vpc_id            = aws_vpc.cc4_vpc.id
  cidr_block        = var.application_subnet_cidr[count.index]
  availability_zone = var.subnet_az[count.index]

  tags = {
    Name = "Application Tier Subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "data_subnet" {
  count = 2

  vpc_id            = aws_vpc.cc4_vpc.id
  cidr_block        = var.data_subnet_cidr[count.index]
  availability_zone = var.subnet_az[count.index]

  tags = {
    Name = "Data Tier Subnet ${count.index + 1}"
  }
}
