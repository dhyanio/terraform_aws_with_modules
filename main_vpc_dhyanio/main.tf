# provider as we all know or understand, its our public cloud service provider, AWS.
# In these codes i am using resource tags names same as their defined variable names, we can we anyname in tags

provider "aws" {
  region = "us-west-2"
}

# Query all avilable Availibility Zone, i am using data source here, it can automatically fetch data.
data "aws_availability_zones" "available_zone" {}

# Now I am creating VPC (main_vpc_dhyanio)

resource "aws_vpc" "main_vpc_dhyanio" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main_vpc_dhyanio"
  }
}

# Now I am Creating Internet Gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.main_vpc_dhyanio.id}"

  tags = {
    Name = "igw"
  }
}

# Creating nat gateway for main_vpc_dhyanio

resource "aws_nat_gateway" "nat_gateway_dhyanio" {
  allocation_id = "${aws_eip.my_eip.id}"
  subnet_id     = "${aws_subnet.public_subnet.0.id}"
}


# Our Public Route Table

resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.main_vpc_dhyanio.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "public_route_table"
  }
}

# Our Private Route Table

resource "aws_default_route_table" "private_route_table" {
  default_route_table_id = "${aws_vpc.main_vpc_dhyanio.default_route_table_id}"

  route {
    nat_gateway_id = "${aws_nat_gateway.nat_gateway_dhyanio.id}"
    cidr_block     = "0.0.0.0/0"
  }

  tags = {
    Name = "my-private-route-table"
  }
}

# Our Public Subnet
resource "aws_subnet" "public_subnet" {
  count                   = 2
  cidr_block              = "${var.public_cidrs[count.index]}"
  vpc_id                  = "${aws_vpc.main_vpc_dhyanio.id}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available_zone.names[count.index]}"

  tags = {
    Name = "public_subnet.${count.index + 1}"
  }
}

# Our Private Subnet
resource "aws_subnet" "private_subnet" {
  count             = 2
  cidr_block        = "${var.private_cidrs[count.index]}"
  vpc_id            = "${aws_vpc.main_vpc_dhyanio.id}"
  availability_zone = "${data.aws_availability_zones.available_zone.names[count.index]}"

  tags = {
    Name = "private_subnet.${count.index + 1}"
  }
}

# Same here, associate Private Subnet with Private Route Table

resource "aws_route_table_association" "private_subnet_assoc" {
  count          = 2
  route_table_id = "${aws_default_route_table.private_route_table.id}"
  subnet_id      = "${aws_subnet.private_subnet.*.id[count.index]}"
  depends_on     = ["aws_default_route_table.private_route_table", "aws_subnet.private_subnet"]
}

#  We have associate our Public Subnet with Public Route Table

resource "aws_route_table_association" "public_subnet_assoc" {
  count          = 2
  route_table_id = "${aws_route_table.public_route_table.id}"
  subnet_id      = "${aws_subnet.public_subnet.*.id[count.index]}"
  depends_on     = ["aws_route_table.public_route_table", "aws_subnet.public_subnet"]
}


# Security Group Creation
resource "aws_security_group" "sg_dhyanio" {
  name   = "security_group1"
  vpc_id = "${aws_vpc.main_vpc_dhyanio.id}"
}
resource "aws_security_group_rule" "http_access" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.sg_dhyanio.id}"
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}


# Ingress Security Port 22
resource "aws_security_group_rule" "ssh_inbound_access" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.sg_dhyanio.id}"
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}


# every outbound cccess
resource "aws_security_group_rule" "all_outbound_access" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.sg_dhyanio.id}"
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

# creating elastic ip.. 

resource "aws_eip" "my_eip" {
  vpc = true
}
