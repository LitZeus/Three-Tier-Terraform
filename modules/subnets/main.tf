resource "aws_subnet" "this_subnet" {
    for_each = {for idx, cidr in var.subnet_cidrs: idx => cidr}

    vpc_id = var.vpc_id
    cidr_block = each.value
    availability_zone = element(var.availability_zones, each.key)
    map_customer_owned_ip_on_launch = var.public_subnet
}

# igw
resource "aws_internet_gateway" "this_igw" {
  count = var.public_subnet ? 1: 0
  vpc_id = var.vpc_id

}

# eip
resource "aws_eip" "eip_nat" {
  count = var.public_subnet ? 0 : length(var.subnet_cidrs)
  vpc = true
}

#nat
resource "aws_nat_gateway" "this_nat" {
    count = var.public_subnet ? 0 : length(var.subnet_cidrs)
    allocation_id = aws_eip.eip_nat[count.table].id
    subnet_id = element(aws_subnet.this_subnet.*.id, count.index % length(aws_subnet.this_subnet.*.id))
}