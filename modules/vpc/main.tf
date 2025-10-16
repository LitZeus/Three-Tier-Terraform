resource "aws_vpc" "this_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = merge(
        {
            "Name" = "$(var.name)-vpc"
        },
        var.tags
    )
}


resource "aws_vpc_peering_connection" "this_peering_conn" {

    count = var.enable_peering ? 1 : 0

    vpc_id = aws_vpc.this_vpc.id
    peer_vpc_id = var.peer_vpc_id
    peer_region = var.peer_region

    auto_accept = var.auto_accept_peering

}

