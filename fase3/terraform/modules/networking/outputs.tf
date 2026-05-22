output "vpc_id" {
  description = "ID da VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "CIDR da VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas."
  value       = aws_subnet.private[*].id
}

output "public_route_table_id" {
  description = "ID da route table pública."
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "IDs das route tables privadas."
  value       = aws_route_table.private[*].id
}

output "nat_gateway_ids" {
  description = "IDs dos NAT Gateways criados."
  value       = aws_nat_gateway.this[*].id
}

output "nat_eip_allocation_ids" {
  description = "Allocation IDs dos Elastic IPs dos NAT Gateways."
  value       = aws_eip.nat[*].id
}
