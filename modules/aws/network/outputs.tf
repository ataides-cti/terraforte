################################################################################
# VPC
################################################################################

output "vpc_id" {
  description = "ID of the VPC."
  value       = var.vpc_id == null ? aws_vpc.this[0].id : var.vpc_id
}

################################################################################
# Subnets
################################################################################

output "public_subnet_ids" {
  description = "List of IDs of the public subnets."
  value       = var.subnets_public_enabled ? aws_subnet.public[*].id : []
}

output "private_subnet_ids" {
  description = "List of IDs of the private subnets."
  value       = var.subnets_private_enabled ? aws_subnet.private[*].id : []
}

################################################################################
# Internet Gateway
################################################################################

output "internet_gateway_id" {
  description = "ID of the Internet Gateway."
  value       = var.igw_enabled ? aws_internet_gateway.this[0].id : null
}

################################################################################
# Elastic IPs and NAT Gateways
################################################################################

output "elastic_ip_ids" {
  description = "List of IDs of the Elastic IPs."
  value       = var.eip_enabled ? aws_eip.this[*].id : []
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs."
  value       = var.ngw_enabled ? aws_nat_gateway.this[*].id : []
}

################################################################################
# Route Tables
################################################################################

output "public_route_table_id" {
  description = "ID of the public route table."
  value       = var.rt_public_enabled ? aws_route_table.public[0].id : null
}

output "private_route_table_ids" {
  description = "List of private route table IDs."
  value       = var.rt_private_enabled ? aws_route_table.private[*].id : []
}

################################################################################
# Network ACLs
################################################################################

output "public_network_acl_id" {
  description = "ID of the public network ACL."
  value       = var.acl_public_enabled ? aws_network_acl.public[0].id : null
}

output "private_network_acl_ids" {
  description = "List of private network ACL IDs."
  value       = var.acl_private_enabled ? aws_network_acl.private[*].id : []
}
