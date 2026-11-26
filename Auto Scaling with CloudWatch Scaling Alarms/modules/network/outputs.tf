output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "availability_zones" {
  description = "Three Availability Zones used for the public and private subnet pairs."
  value       = local.availability_zones
}

output "public_subnet_ids" {
  description = "IDs of the three public subnets."
  value       = [for zone in local.availability_zones : aws_subnet.public[zone].id]
}

output "private_subnet_ids" {
  description = "IDs of the three private subnets."
  value       = [for zone in local.availability_zones : aws_subnet.private[zone].id]
}
