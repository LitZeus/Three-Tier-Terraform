output "subnet_ids" {
  description = "List of subnet IDs"
  value       = [for s in aws_subnet.this : s.id]
}

output "igw_id" {
  description = "IGW ID if created"
  value       = try(aws_internet_gateway.this[0].id, null)
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs if created"
  value       = [for n in aws_nat_gateway.this : n.id]
}
