output "vpc_id" {
  value = aws_vpc.this_vpc.id
}

output "vpc_cidr" {
  value = aws_vpc.this_vpc.cidr_block
}

output "peer_conn_id" {
  value = var.enable_peering ? aws_vpc_peering_connection.this_peering_conn[0].id : null
}