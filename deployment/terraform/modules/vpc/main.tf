resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = merge({
    Name = "${var.prefix}-vpc"
  }, var.common_tags)
}

resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet_cidr_block)

  vpc_id = aws_vpc.vpc.id
  cidr_block = element(var.public_subnet_cidr_block, count.index)

  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "${var.prefix}-public_subnet_${count.index}"
  }
}

resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet_cidr_block)

  vpc_id = aws_vpc.vpc.id
  cidr_block = element(var.private_subnet_cidr_block, count.index)

  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "${var.prefix}-private_subnet_${count.index}"
  }
}

