resource "aws_vpc" "cc4-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "CC4 Vpc"
  }
}

resource "aws_subnet" "presentation-subnet" {
  count = 2

  vpc_id            = aws_vpc.cc4-vpc.id
  cidr_block        = var.presentation-subnet-cidr[count.index]
  availability_zone = var.subnet-az[count.index]

  tags = {
    Name = "Presentation Tier Subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "application-subnet" {
  count = 2

  vpc_id            = aws_vpc.cc4-vpc.id
  cidr_block        = var.application-subnet-cidr[count.index]
  availability_zone = var.subnet-az[count.index]

  tags = {
    Name = "Application Tier Subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "data-subnet" {
  count = 2

  vpc_id            = aws_vpc.cc4-vpc.id
  cidr_block        = var.data-subnet-cidr[count.index]
  availability_zone = var.subnet-az[count.index]

  tags = {
    Name = "Data Tier Subnet ${count.index + 1}"
  }
}
