provider "aws" {
	access_key = "AKIAIMLS4I4VSWW3C75A"
	secret_key = "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"
}

resource "aws_vpc" "vpc" {
	cidr_block = "${var.private_cidr}"
	enable_dns_support = false
	enable_dns_hostnames = false
	tags {
		Name = "vpc"
	}
}
/*
--- AWS INTERNET GATEWAY VPC
*/
resource "aws_internet_gateway" "igw" {
	vpc_id = "${aws_vpc.vpc.id}"
	tags {
		Name  = "igw"
	}
}
/*
--- AWS PUBLIC SUBNET  VPC
*/
resource "aws_subnet" "public" {
	vpc_id = "${aws_vpc.vpc.id}"
	count  = "${length(split(",", var.public_subnets_cidr))}"
	cidr_block  = "${element(split(",", var.public_subnets_cidr), count.index)}"
	availability_zone  = "${var.region}${element(var.availability_zones, count.index)}"
	map_public_ip_on_launch = false
	tags {
		Name = "${var.environment}-public-${var.region}${element(var.availability_zones, count.index)}"
	}
}
output "public_subnets_id" {
	value = "${join(",", aws_subnet.public.*.id)}"
}
resource "aws_route_table" "public" {
	vpc_id = "${aws_vpc.vpc.id}"

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.igw.id}"
	}

	tags {
		Name = "${var.environment}-public"
	}
}
resource "aws_route_table_association" "public" {
	count = "${length(split(",", var.public_subnets_cidr))}"
	subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
	route_table_id = "${aws_route_table.public.id}"
}

// Create the Private Subnets
resource "aws_subnet" "private" {
	vpc_id  = "${aws_vpc.vpc.id}"
	count = "${length(split(",", var.private_subnets_cidr))}"
	cidr_block = "${element(split(",", var.private_subnets_cidr), count.index)}"
	availability_zone = "${var.region}${element(var.availability_zones, count.index)}"
	map_public_ip_on_launch = false

	tags {
		Name = "${var.environment}-private-${var.region}${element(var.availability_zones, count.index)}"
	}
}
output "private_subnets_id" {
	value = "${join(",", aws_subnet.private.*.id)}"
}
/*
--- AWS NAT
*/
resource "aws_eip" "nat" {
	count     = "${length(split(",", var.public_subnets_cidr))}"
}

resource "aws_nat_gateway" "nat" {
	depends_on = ["aws_eip.nat"]
	count = "${length(split(",", var.public_subnets_cidr))}"
	allocation_id  = "${element(aws_eip.nat.*.id, count.index)}"
	subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
}
resource "aws_route_table" "private0" {
	depends_on = ["aws_nat_gateway.nat"]
	vpc_id = "${aws_vpc.vpc.id}"
	route {
		cidr_block = "0.0.0.0/0"
		nat_gateway_id = "${aws_nat_gateway.nat.0.id}"
	}
	tags {
		Name = "${var.environment}-private0"
	}
}
resource "aws_route_table" "private1" {
	depends_on = ["aws_nat_gateway.nat"]
	vpc_id = "${aws_vpc.vpc.id}"
	route {
		cidr_block = "0.0.0.0/0"
		nat_gateway_id = "${aws_nat_gateway.nat.1.id}"
	}
	tags {
		Name = "${var.environment}-private2"
	}
}
resource "aws_route_table" "private2" {
	depends_on = ["aws_nat_gateway.nat"]
	vpc_id = "${aws_vpc.vpc.id}"
	route {
		cidr_block = "0.0.0.0/0"
		nat_gateway_id = "${aws_nat_gateway.nat.2.id}"
	}
	tags {
		Name = "${var.environment}-private3"
	}
}
resource "aws_route_table_association" "private0" {
	depends_on = ["aws_route_table.private0"]
	subnet_id = "${aws_subnet.private.0.id}"
	route_table_id = "${aws_route_table.private0.id}"
}
resource "aws_route_table_association" "private1" {
	depends_on = ["aws_route_table.private1"]
	subnet_id = "${aws_subnet.private.1.id}"
	route_table_id = "${aws_route_table.private1.id}"
}
resource "aws_route_table_association" "private2" {
	depends_on = ["aws_route_table.private2"]
	subnet_id = "${aws_subnet.private.2.id}"
	route_table_id = "${aws_route_table.private2.id}"
}
