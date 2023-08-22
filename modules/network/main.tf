locals {
  az1 = "${var.region}a"
  az2 = "${var.region}b"
  az3 = "${var.region}c"
}

### VPC ###
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-${var.workload}"
  }
}

### Internet Gateway ###

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "ig-${var.workload}"
  }
}

### Subnets ###

module "private" {
  source   = "./private"
  vpc_id   = aws_vpc.main.id
  workload = var.workload

  az1 = local.az1
  az2 = local.az2
  az3 = local.az3
}

module "public" {
  source              = "./public"
  vpc_id              = aws_vpc.main.id
  interget_gateway_id = aws_internet_gateway.main.id
  workload            = var.workload

  az1 = local.az1
  az2 = local.az2
  az3 = local.az3
}

resource "aws_default_route_table" "internet" {
  default_route_table_id = aws_vpc.main.default_route_table_id
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id
}
