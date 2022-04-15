

locals {
  default_tags = { "Env" = "${terraform.workspace}" }
  name_prefix  = "${terraform.workspace}-Group20-Sohel"
}


# Query all avilable Availibility Zone
data "aws_availability_zones" "available" {}

# VPC Creation

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr//"${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.default_tags,
    {"Name"="${local.name_prefix}-VPC"}
  )
}

# Creating Internet Gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"
tags = merge(
  local.default_tags,
  {"Name"="${local.name_prefix}-IGW"}
  )
}

# Public Route Table

resource "aws_route_table" "public_route" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = merge(
  local.default_tags,
  {"Name"="${local.name_prefix}-PublicRouteTable"}
  )
}

# Private Route Table

resource "aws_route_table" "private_route" {
  //route_table_id = "${aws_vpc.main.default_route_table_id}"
 vpc_id = "${aws_vpc.main.id}"
  route {
    //nat_gateway_id = aws_nat_gateway.my-test-nat-gateway.id
    gateway_id = aws_internet_gateway.gw.id  //Logically it should be natgateway here but its not working, I cannot find the error
    cidr_block     = "0.0.0.0/0"
  }

  tags = merge(
  local.default_tags,
  {"Name"="${local.name_prefix}-PrivateRouteTable"}
  )
}

# Three Public Subnet
resource "aws_subnet" "public_subnet" {
  count                   = 3
  cidr_block              = "${var.public_cidrs[count.index]}"
  vpc_id                  = "${aws_vpc.main.id}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"

  tags = merge(
  local.default_tags,
  {"Name"="${local.name_prefix}-PublicSubnet${count.index + 1}"}
  )
}

# Three Private Subnet
resource "aws_subnet" "private_subnet" {
  count             = 3
  cidr_block        = "${var.private_cidrs[count.index]}"
  vpc_id            = "${aws_vpc.main.id}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  tags = merge(
  local.default_tags,
  {"Name"="${local.name_prefix}-PrivateSubnet${count.index + 1}"}
  )
}

# Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public_subnet_assoc" {
  count          = 3
  route_table_id = "${aws_route_table.public_route.id}"
  subnet_id      = "${aws_subnet.public_subnet.*.id[count.index]}"
  depends_on     = [aws_route_table.public_route, aws_subnet.public_subnet]
}

# Associate Private Subnet with Private Route Table
resource "aws_route_table_association" "private_subnet_assoc" {
  count          = 3
  route_table_id = "${aws_route_table.private_route.id}"
  subnet_id      = "${aws_subnet.private_subnet.*.id[count.index]}"
  depends_on     = [aws_route_table.private_route,aws_subnet.private_subnet]
}

# Security Group Creation
resource "aws_security_group" "test_sg" {
  name   = "${local.name_prefix}-VPC-SG"
  vpc_id = "${aws_vpc.main.id}"
}

# Ingress Security Port 22
resource "aws_security_group_rule" "ssh_inbound_access" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.test_sg.id}"
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "http_inbound_access" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.test_sg.id}"
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

# All OutBound Access
resource "aws_security_group_rule" "all_outbound_access" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.test_sg.id}"
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_eip" "my-test-eip" {
  vpc = true
}

resource "aws_nat_gateway" "my-test-nat-gateway" {
  allocation_id = "${aws_eip.my-test-eip.id}"
  subnet_id     = "${aws_subnet.public_subnet.0.id}"
  depends_on = [aws_internet_gateway.gw]
  tags= {
    Name="${local.name_prefix}-NatGW"
  }
}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "bastion" {
  #count  = length(data.terraform_remote_state.network.outputs.private_subnet_ids)
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.bastion_key.key_name
  subnet_id                   = aws_subnet.public_subnet.0.id
  security_groups             = [aws_security_group.test_sg.id]
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-Bastion"
    }
  )
}