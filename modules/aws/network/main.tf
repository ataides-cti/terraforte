locals {
  # Tags
  internal_tags = {
    ManagedBy = "terraform"
    Source    = "terraforte"
    Version   = "0.1.0"
  }

  # VPC
  vpc_id = var.vpc_id == null ? aws_vpc.this[0].id : var.vpc_id

  # Subnets
  subnet_azs_names = length(var.subnets_azs_names) == 0 ? data.aws_availability_zones.available.names : var.subnets_azs_names
}

data "aws_availability_zones" "available" {
  state = "available"
}

################################################################################
# VPC
################################################################################

resource "aws_vpc" "this" {
  count = var.vpc_id == null ? 1 : 0

  cidr_block          = var.ipv4_cidr_block
  ipv4_ipam_pool_id   = try(var.ipv4_ipam_pool.pool_id, null)
  ipv4_netmask_length = try(var.ipv4_ipam_pool.netmask_length, null)

  assign_generated_ipv6_cidr_block = var.vpc_assign_generated_ipv6_cidr_block
  ipv6_ipam_pool_id                = try(var.ipv6_ipam_pool.pool_id, null)
  ipv6_cidr_block                  = try(var.ipv6_ipam_pool.cidr_block, null)
  ipv6_netmask_length              = try(var.ipv6_ipam_pool.netmask_length, null)

  instance_tenancy                     = var.vpc_instance_tenancy
  enable_dns_support                   = var.vpc_enable_dns_support
  enable_dns_hostnames                 = var.vpc_enable_dns_hostnames
  enable_network_address_usage_metrics = var.vpc_enable_network_address_usage_metrics

  tags = merge(
    { Name = format("%s-vpc", var.name) },
    local.internal_tags,
    var.global_tags,
    var.vpc_tags,
  )
}

################################################################################
# Internet Gateway
################################################################################

resource "aws_internet_gateway" "this" {
  count = var.igw_enabled ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    { Name = format("%s-igw", var.name) },
    local.internal_tags,
    var.global_tags,
    var.igw_tags,
  )
}

################################################################################
# Subnets
################################################################################

resource "aws_subnet" "public" {
  count = var.subnets_public_enabled ? var.azs_count : 0

  vpc_id            = local.vpc_id
  availability_zone = local.subnet_azs_names[count.index]

  cidr_block = cidrsubnet(var.ipv4_cidr_block, var.subnets_ipv4_cidr_newbits, count.index)

  enable_dns64                                   = var.subnets_public_enable_dns64
  map_public_ip_on_launch                        = var.subnets_public_map_public_ip_on_launch
  assign_ipv6_address_on_creation                = var.subnets_public_assign_ipv6_address_on_creation
  enable_resource_name_dns_a_record_on_launch    = var.subnets_public_enable_resource_name_dns_a_record_on_launch
  enable_resource_name_dns_aaaa_record_on_launch = var.subnets_public_enable_resource_name_dns_aaaa_record_on_launch

  depends_on = [aws_internet_gateway.this]

  tags = merge(
    { Name = format("%s-subnet-public-%s", var.name, local.subnet_azs_names[count.index]) },
    local.internal_tags,
    var.global_tags,
    var.subnets_tags,
    var.subnets_public_tags,
  )
}

resource "aws_subnet" "private" {
  count = var.subnets_private_enabled ? var.azs_count : 0

  vpc_id            = local.vpc_id
  availability_zone = local.subnet_azs_names[count.index]

  cidr_block = cidrsubnet(var.ipv4_cidr_block, var.subnets_ipv4_cidr_newbits, count.index + var.subnets_private_ipv4_cidr_offset)

  enable_dns64                                   = var.subnets_private_enable_dns64
  private_dns_hostname_type_on_launch            = var.subnets_private_dns_hostname_type
  assign_ipv6_address_on_creation                = var.subnets_private_assign_ipv6_address_on_creation
  enable_resource_name_dns_a_record_on_launch    = var.subnets_private_enable_resource_name_dns_a_record_on_launch
  enable_resource_name_dns_aaaa_record_on_launch = var.subnets_private_enable_resource_name_dns_aaaa_record_on_launch

  tags = merge(
    { Name = format("%s-subnet-private-%s", var.name, local.subnet_azs_names[count.index]) },
    local.internal_tags,
    var.global_tags,
    var.subnets_tags,
    var.subnets_private_tags,
  )
}

################################################################################
# Route Tables
################################################################################

# Public Route Table
resource "aws_route_table" "public" {
  count = var.rt_public_enabled && var.subnets_public_enabled ? 1 : 0

  vpc_id = local.vpc_id

  depends_on = [aws_subnet.public]

  tags = merge(
    { Name = format("%s-route-table-public", var.name) },
    local.internal_tags,
    var.global_tags,
    var.rt_tags,
    var.rt_public_tags,
  )
}

resource "aws_route" "public" {
  count = var.rt_public_enabled && var.subnets_public_enabled ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_route_table_association" "public" {
  count = var.rt_public_enabled && var.subnets_public_enabled ? var.azs_count : 0

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

# Private Route Table
resource "aws_route_table" "private" {
  count = var.rt_private_enabled && var.subnets_private_enabled ? var.azs_count : 0

  vpc_id = local.vpc_id

  depends_on = [aws_subnet.private]

  tags = merge(
    { Name = format("%s-route-table-private-%s", var.name, local.subnet_azs_names[count.index]) },
    local.internal_tags,
    var.global_tags,
    var.rt_tags,
    var.rt_private_tags,
  )
}

resource "aws_route_table_association" "private" {
  count = var.rt_private_enabled && var.subnets_private_enabled ? var.azs_count : 0

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

################################################################################
# Elastic IP
################################################################################

resource "aws_eip" "this" {
  count  = var.eip_enabled ? var.azs_count : 0
  domain = "vpc"

  ipam_pool_id = try(var.ipv4_ipam_pool.pool_id, null)

  tags = merge(
    { Name = format("%s-eip-%s", var.name, local.subnet_azs_names[count.index]) },
    local.internal_tags,
    var.global_tags,
    var.eip_tags,
  )
}

################################################################################
# NAT Gateway
################################################################################

resource "aws_nat_gateway" "this" {
  count = var.eip_enabled && var.ngw_enabled ? var.ngw_count : 0

  allocation_id = aws_eip.this[count.index].id

  connectivity_type = var.ngw_connectivity_type
  subnet_id         = var.ngw_connectivity_type == "public" ? aws_subnet.public[count.index].id : aws_subnet.private[count.index].id

  depends_on = [aws_eip.this]

  tags = merge(
    { Name = format("%s-ngw-%s", var.name, local.subnet_azs_names[count.index]) },
    local.internal_tags,
    var.global_tags,
    var.ngw_tags,
  )
}

# A route to the NAT gateway for private subnets is required to allow private subnets to access the internet.
resource "aws_route" "ngw" {
  count = var.ngw_enabled && var.ngw_connectivity_type == "private" ? var.ngw_count : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id

  depends_on = [aws_nat_gateway.this, aws_route_table.private]
}

################################################################################
# Network ACLs
################################################################################

resource "aws_network_acl" "public" {
  count = var.acl_public_enabled && var.subnets_public_enabled ? 1 : 0

  vpc_id     = local.vpc_id
  subnet_ids = aws_subnet.public[*].id

  dynamic "ingress" {
    for_each = var.acl_public_ingress_rules
    content {
      rule_no    = ingress.value.number
      protocol   = ingress.value.protocol
      action     = ingress.value.action
      cidr_block = ingress.value.cidr_block
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
    }
  }

  dynamic "egress" {
    for_each = var.acl_public_egress_rules
    content {
      rule_no    = egress.value.number
      protocol   = egress.value.protocol
      action     = egress.value.action
      cidr_block = egress.value.cidr_block
      from_port  = egress.value.from_port
      to_port    = egress.value.to_port
    }
  }

  tags = merge(
    { Name = format("%s-acl-public", var.name) },
    local.internal_tags,
    var.global_tags,
    var.acl_tags,
    var.acl_public_tags,
  )
}

resource "aws_network_acl" "private" {
  count = var.acl_private_enabled && var.subnets_private_enabled ? var.azs_count : 0

  vpc_id     = local.vpc_id
  subnet_ids = aws_subnet.private[*].id

  dynamic "ingress" {
    for_each = var.acl_private_ingress_rules
    content {
      rule_no    = ingress.value.number
      protocol   = ingress.value.protocol
      action     = ingress.value.action
      cidr_block = ingress.value.cidr_block
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
    }
  }

  dynamic "egress" {
    for_each = var.acl_private_egress_rules
    content {
      rule_no    = egress.value.number
      protocol   = egress.value.protocol
      action     = egress.value.action
      cidr_block = egress.value.cidr_block
      from_port  = egress.value.from_port
      to_port    = egress.value.to_port
    }
  }

  tags = merge(
    { Name = format("%s-acl-private-%s", var.name, local.subnet_azs_names[count.index]) },
    local.internal_tags,
    var.global_tags,
    var.acl_tags,
    var.acl_private_tags,
  )
}
