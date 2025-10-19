resource "aws_subnet" "this" {
  count = length(var.subnet_cidrs)

  vpc_id                  = var.vpc_id
  cidr_block              = var.subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = var.public

  tags = {
    Name = "${var.public ? "public" : "private"}-subnet-${count.index + 1}"
  }
}