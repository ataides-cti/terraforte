################################################################################
# General
################################################################################

variable "name" {
  type        = string
  description = "Name to be used on all the resources as identifier"
  default     = "terraforte"
  nullable    = false
}

variable "global_tags" {
  type        = map(string)
  description = <<-EOT
    Tags to apply to all resources.

    Recommended keys:
      - Owner
      - Environment
      - Project
      - Tenant
  EOT
  default     = {}
}

variable "azs_count" {
  type        = number
  description = "The number of Availability Zones to use."
  default     = 2
  nullable    = false
  validation {
    condition     = var.subnets_azs_count >= 1 && var.subnets_azs_count <= 4
    error_message = "The number of Availability Zones must be between 1 and 4."
  }
}

variable "ipv4_cidr_block" {
  type        = string
  description = "The IPv4 CIDR block for the network."
  default     = null
  validation {
    condition     = can(cidrhost(var.ipv4_cidr_block, 0)) && tonumber(split("/", var.ipv4_cidr_block)[1]) >= 16 && tonumber(split("/", var.ipv4_cidr_block)[1]) <= 28
    error_message = "Invalid IPv4 CIDR block. Must be between /16 and /28."
  }
}

################################################################################
# IPAM
################################################################################

variable "ipv4_ipam_pool" {
  type = object({
    pool_id   = string
    netmask_length = number
  })
  description = "The IPv4 IPAM pool to use for allocating this VPC's CIDR. Cannot be used with ipv4_cidr_block."
  default     = null
  validation {
    condition     = var.ipv4_ipam_pool != null && var.ipv4_cidr_block != null
    error_message = "ipv4_ipam_pool cannot be used with ipv4_cidr_block."
  }
}

variable "ipv6_ipam_pool" {
  type = object({
    pool_id   = string
    cidr_block     = string
    netmask_length = number
  })
  description = "The IPv6 IPAM pool to use for allocating this VPC's CIDR. Cannot be used with assign_generated_ipv6_cidr_block."
  default     = null
  validation {
    condition     = var.ipv6_ipam_pool != null && var.assign_generated_ipv6_cidr_block != null
    error_message = "ipv6_ipam_pool cannot be used with assign_generated_ipv6_cidr_block."
  }
}

################################################################################
# VPC
################################################################################

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to use. If not provided, a new VPC will be created."
  default     = null
}

variable "vpc_assign_generated_ipv6_cidr_block" {
  type        = bool
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. Conflicts with ipv6_ipam_pool."
  default     = false
  nullable    = false
}

variable "vpc_instance_tenancy" {
  type        = string
  description = "The allowed tenancy of instances launched into the VPC."
  default     = "default"
  nullable    = false
  validation {
    condition     = contains(["default", "dedicated"], var.instance_tenancy)
    error_message = "Invalid instance tenancy. Must be either 'default' or 'dedicated'."
  }
}

variable "vpc_enable_dns_support" {
  type        = bool
  description = "Control to enable/disable DNS support in the VPC."
  default     = true
  nullable    = false
}

variable "vpc_enable_dns_hostnames" {
  type        = bool
  description = "Control to enable/disable DNS hostnames in the VPC."
  default     = true
  nullable    = false
}

variable "vpc_enable_network_address_usage_metrics" {
  type        = bool
  description = "Control to enable/disable network address usage metrics in the VPC."
  default     = true
  nullable    = false
}

variable "vpc_tags" {
  type        = map(string)
  description = "Additional tags for the VPC."
  default     = {}
}

################################################################################
# Internet Gateway
################################################################################

variable "igw_enabled" {
  type        = bool
  description = "Control to deploy internet gateway."
  default     = true
  nullable    = false
}

variable "igw_tags" {
  type        = map(string)
  description = "Additional tags for the internet gateway."
  default     = {}
}

################################################################################
# Subnets
################################################################################

variable "subnets_azs_names" {
  type        = list(string)
  description = <<-EOT
    (Optional) The names of the Availability Zones to use for the subnets.
    If not provided, the Availability Zones will be automatically selected.
  EOT
  default     = []
  nullable    = false
  validation {
    condition     = var.subnets_azs_names == [] ? var.subnets_azs_count == length(data.aws_availability_zones.available.names) : var.subnets_azs_count == length(var.subnets_azs_names)
    error_message = "The number of Availability Zones must be equal to the number of Availability Zone names."
  }
}

variable "subnets_ipv4_cidr_newbits" {
  type        = number
  description = "The number of newbits to add to the CIDR block for the subnets."
  default     = 4
  nullable    = false
  validation {
    condition     = var.subnets_ipv4_cidr_newbits >= 0 && var.subnets_ipv4_cidr_newbits <= 8
    error_message = "The number of newbits must be between 0 and 8."
  }
}

variable "subnets_tags" {
  type        = map(string)
  description = "Additional tags for the subnets."
  default     = {}
}

# Public subnets
variable "subnets_public_enabled" {
  type        = bool
  description = "Control to deploy public subnets."
  default     = true
  nullable    = false
}

variable "subnets_public_enable_dns64" {
  type        = bool
  description = "Control to enable/disable DNS64 for the public subnets."
  default     = false
  nullable    = false
}

variable "subnets_public_map_public_ip_on_launch" {
  type        = bool
  description = "Control to map public IP on launch for the public subnets."
  default     = false
  nullable    = false
}

variable "subnets_public_enable_resource_name_dns_a_record_on_launch" {
  type        = bool
  description = "Control to enable/disable resource name DNS A record on launch for the public subnets."
  default     = false
  nullable    = false
}

variable "subnets_public_enable_resource_name_dns_aaaa_record_on_launch" {
  type        = bool
  description = "Control to enable/disable resource name DNS AAAA record on launch for the public subnets."
  default     = false
  nullable    = false
}

variable "subnets_public_assign_ipv6_address_on_creation" {
  type        = bool
  description = "Control to assign IPv6 address on creation for the public subnets."
  default     = false
  nullable    = false
}

variable "subnets_public_tags" {
  type        = map(string)
  description = "Additional tags for the public subnets."
  default     = {}
}

# Private subnets
variable "subnets_private_enabled" {
  type        = bool
  description = "Control to deploy private subnets."
  default     = true
  nullable    = false
}

variable "subnets_private_ipv4_cidr_offset" {
  type        = number
  description = "The offset to add to the CIDR block for the private subnets."
  default     = 100
  nullable    = false
  validation {
    condition     = var.subnets_private_ipv4_cidr_offset > var.subnets_azs_count
    error_message = "The private subnet offset must be greater than the number of AZs."
  }
}

variable "subnets_private_enable_dns64" {
  type        = bool
  description = "Control to enable/disable DNS64 for the private subnets."
  default     = false
  nullable    = false
}

variable "subnets_private_dns_hostname_type" {
  type        = string
  description = "The type of hostname to assign to the private subnets."
  default     = "ip-name"
  nullable    = false
}

variable "subnets_private_enable_resource_name_dns_a_record_on_launch" {
  type        = bool
  description = "Control to enable/disable resource name DNS A record on launch for the private subnets."
  default     = false
  nullable    = false
}

variable "subnets_private_enable_resource_name_dns_aaaa_record_on_launch" {
  type        = bool
  description = "Control to enable/disable resource name DNS AAAA record on launch for the private subnets."
  default     = false
  nullable    = false
}

variable "subnets_private_assign_ipv6_address_on_creation" {
  type        = bool
  description = "Control to assign IPv6 address on creation for the private subnets."
  default     = false
  nullable    = false
}

variable "subnets_private_tags" {
  type        = map(string)
  description = "Additional tags for the private subnets."
  default     = {}
}

################################################################################
# Route Tables
################################################################################

variable "rt_tags" {
  type        = map(string)
  description = "Additional tags for the route tables."
  default     = {}
}

variable "rt_public_enabled" {
  type        = bool
  description = "Control to deploy public route table."
  default     = true
  nullable    = false
}

variable "rt_public_tags" {
  type        = map(string)
  description = "Additional tags for the public route table."
  default     = {}
}

variable "rt_private_enabled" {
  type        = bool
  description = "Control to deploy private route tables."
  default     = true
  nullable    = false
}

variable "rt_private_tags" {
  type        = map(string)
  description = "Additional tags for the private route tables."
  default     = {}
}

################################################################################
# Elastic IP
################################################################################

variable "eip_enabled" {
  type        = bool
  description = "Control to deploy elastic IPs."
  default     = true
  nullable    = false
}

variable "eip_tags" {
  type        = map(string)
  description = "Additional tags for the elastic IPs."
  default     = {}
}

################################################################################
# NAT Gateway
################################################################################

variable "ngw_enabled" {
  type        = bool
  description = "Control to deploy NAT gateways."
  default     = true
  nullable    = false
}

variable "ngw_count" {
  type        = number
  description = "The number of NAT gateways to deploy."
  default     = var.azs_count
  nullable    = false
  validation {
    condition     = var.ngw_count >= 1 && var.ngw_count <= var.azs_count
    error_message = "The number of NAT gateways must be between 1 and the number of Availability Zones."
  }
}

variable "ngw_connectivity_type" {
  type        = string
  description = "The type of connectivity for the NAT gateway."
  default     = "private"
  nullable    = false
  validation {
    condition     = contains(["public", "private"], var.ngw_connectivity_type)
    error_message = "Invalid connectivity type. Must be either 'public' or 'private'."
  }
}

variable "ngw_tags" {
  type        = map(string)
  description = "Additional tags for the NAT gateways."
  default     = {}
}

################################################################################
# Network ACLs
################################################################################

variable "acl_tags" {
  type        = map(string)
  description = "Additional tags for the network ACLs."
  default     = {}
}

variable "acl_public_enabled" {
  type        = bool
  description = "Control to deploy public network ACL."
  default     = true
  nullable    = false
}

variable "acl_public_ingress_rules" {
  type        = list(object({
    protocol = string
    number = number
    action = string
    cidr_block = string
    from_port = number
    to_port = number
  }))
  description = "Ingress rules for the public network ACL."
  default     = []
  nullable    = false
}

variable "acl_public_egress_rules" {
  type        = list(object({
    protocol = string
    number = number
    action = string
    cidr_block = string
    from_port = number
    to_port = number
  }))
  description = "Egress rules for the public network ACL."
  default     = []
  nullable    = false
}

variable "acl_public_tags" {
  type        = map(string)
  description = "Additional tags for the public network ACL."
  default     = {}
}

variable "acl_private_enabled" {
  type        = bool
  description = "Control to deploy private network ACLs."
  default     = true
  nullable    = false
}


variable "acl_private_ingress_rules" {
  type        = list(object({
    protocol = string
    number = number
    action = string
    cidr_block = string
    from_port = number
    to_port = number
  }))
  description = "Ingress rules for the private network ACLs."
  default     = []
  nullable    = false
}

variable "acl_private_egress_rules" {
  type        = list(object({
    rule_number = number
    rule_protocol = string
    rule_action = string
    rule_cidr_block = string
    rule_from_port = number
    rule_to_port = number
  }))
  description = "Egress rules for the private network ACLs."
  default     = []
  nullable    = false
}

variable "acl_private_tags" {
  type        = map(string)
  description = "Additional tags for the private network ACLs."
  default     = {}
}
