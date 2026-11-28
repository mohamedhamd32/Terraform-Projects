output "vpc_id" {
  description = "VPC ID."
  value       = aws_vpc.this.id
}

output "azs" {
  description = "Availability Zones used."
  value       = local.azs
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = aws_subnet.public[*].id

  depends_on = [aws_route_table_association.public]
}

output "private_subnet_ids" {
  description = "Private subnet IDs. Only returned once the NAT route is in place, so nodes can join the cluster."
  value       = aws_subnet.private[*].id

  depends_on = [aws_route_table_association.private]
}

output "nat_gateway_public_ip" {
  description = "Public IP used by private subnets for outbound traffic."
  value       = aws_eip.nat.public_ip
}
