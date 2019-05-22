# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_hostnames = true

  tags {
    Name = "${var.namespace}-vpc"
  }
}

data "aws_availability_zones" "available" {}

locals {
  az_names       = ["${data.aws_availability_zones.available.names.0}","${data.aws_availability_zones.available.names.1}"]
  az_count       = "${length(local.az_names)}"
  az_identifiers = ["${substr(data.aws_availability_zones.available.names.0, -1, 1)}","${substr(data.aws_availability_zones.available.names.1, -1, 1)}"]
}


# Create subnets
resource "aws_subnet" "private" {
  count             = "${local.az_count}"
  vpc_id            = "${aws_vpc.main.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.main.cidr_block, 4, count.index)}"
  availability_zone = "${element(local.az_names, count.index)}"

  tags {
    Name = "${var.namespace}-subnet-private-${element(local.az_identifiers, count.index)}"
  }
}

resource "aws_subnet" "public" {
  count                   = "${local.az_count}"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.main.cidr_block, 4, count.index + length(aws_subnet.private.*.id))}"
  availability_zone       = "${element(local.az_names, count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.namespace}-subnet-public-${element(local.az_identifiers, count.index)}"
  }
}

# Create gateways
resource "aws_eip" "nat" {
  count = "${local.az_count}"
  vpc   = true
}

resource "aws_nat_gateway" "main" {
  count         = "${local.az_count}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"

  tags {
    Name = "${var.namespace}-ng-${element(local.az_identifiers, count.index)}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.namespace}-ig"
  }
}

# Create route tables
resource "aws_route_table" "private" {
  count  = "${local.az_count}"
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.namespace}-rt-private-${element(local.az_identifiers, count.index)}"
  }
}

resource "aws_route" "nat_gateway" {
  count                  = "${local.az_count}"
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.main.*.id, count.index)}"
}

resource "aws_route_table_association" "private" {
  count          = "${local.az_count}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.namespace}-rt-public"
  }
}

resource "aws_route" "internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.main.id}"
}

resource "aws_route_table_association" "public" {
  count          = "${local.az_count}"
  route_table_id = "${aws_route_table.public.id}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
}
