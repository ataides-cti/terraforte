# Terraforte - AWS - Network

This Terraform module creates a complete AWS networking infrastructure. At its core, this module creates a Virtual Private Cloud (VPC) that serves as the foundation of your AWS network. The VPC comes with all the essential networking components you'd expect:

- A robust VPC with support for both IPv4 and IPv6 addressing. You can either specify your own CIDR blocks or leverage AWS's IP Address Management (IPAM) system for automated IP allocation. The VPC is configured with modern best practices, including DNS support and hostname resolution.
- For internet connectivity, the module sets up an Internet Gateway that allows your public resources to communicate with the internet. This is complemented by a set of public subnets where you can place resources that need direct internet access.
- To protect your internal resources, the module creates private subnets that are isolated from the internet. These private subnets can still access the internet through NAT Gateways, which the module can automatically provision. This setup gives you the best of both worlds: security for your internal resources and internet access when needed.
- Multiple Availability Zones for high availability. Each zone gets its own set of subnets and route tables, ensuring your applications remain resilient even if an entire availability zone goes down.
- Security is handled through Network ACLs (Access Control Lists) that act as a firewall for your subnets. You can define custom rules for both incoming and outgoing traffic, giving you fine-grained control over network access.

This module follows AWS best practices and includes several quality-of-life features:

- All resources are automatically tagged with metadata about their management source and version
- The module supports both IPv4 and IPv6 addressing
- Security groups are intentionally excluded as they're typically used to manage individual instances such as EC2 and RDS
- The infrastructure is designed to be highly available across multiple Availability Zones

## Example

Here's a simple example of how to use this module:

```hcl
module "network" {
  source = "terraforte/aws/network"
  version = "X.Y.Z"

  name = "my-network"
  azs_count = 3
  ipv4_cidr_block = "10.0.0.0/16"
  subnets_public_map_public_ip_on_launch = true
  ngw_enabled = false

  acl_public_egress_rules = [
    {
      protocol = "-1"
      number = 100
      action = "allow"
      cidr_block = "0.0.0.0/0"
      from_port = 0
      to_port = 0
    }
  ]

  acl_public_ingress_rules = [
    {
      protocol = "-1"
      number = 100
      action = "allow"
      cidr_block = "0.0.0.0/0"
      from_port = 0
      to_port = 0
    }
  ]

  global_tags = {
    Owner       = "John Doe"
    Tenant      = "my-tenant"
    Environment = "production"
    Project     = "my-project"
  }
}
```

See the [examples folder](./examples/) for more working examples.

## Requirements

| Name | Version |
|------|---------|
| [Terraform](https://developer.hashicorp.com/terraform) | >= 1.12 |
| [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws) | >= 6.0.0-beta2 |

## Inputs

python3 scripts/generate_md_from_tfvars.py modules/aws/network
| Name | Description | Default | Type |
|------|-------------|---------|------|
| `name` | Name to be used on all the resources as identifier | `terraforte` | string |
| `global_tags` | Tags to apply to all resources. | `{}` | ${map(string)} |
| `azs_count` | The number of Availability Zones to use. | `2` | number |
| `ipv4_cidr_block` | The IPv4 CIDR block for the network. | `None` | string |
| `ipv4_ipam_pool` | The IPv4 IPAM pool to use for allocating this VPC's CIDR. Cannot be used with ipv4_cidr_block. | `None` | ${object({"pool_id": "string", "netmask_length": "number"})} |
| `ipv6_ipam_pool` | The IPv6 IPAM pool to use for allocating this VPC's CIDR. Cannot be used with assign_generated_ipv6_cidr_block. | `None` | ${object({"pool_id": "string", "cidr_block": "string", "netmask_length": "number"})} |
| `vpc_id` | The ID of the VPC to use. If not provided, a new VPC will be created. | `None` | string |
| `vpc_assign_generated_ipv6_cidr_block` | Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. Conflicts with ipv6_ipam_pool. | `False` | bool |
| `vpc_instance_tenancy` | The allowed tenancy of instances launched into the VPC. | `default` | string |
| `vpc_enable_dns_support` | Control to enable/disable DNS support in the VPC. | `True` | bool |
| `vpc_enable_dns_hostnames` | Control to enable/disable DNS hostnames in the VPC. | `True` | bool |
| `vpc_enable_network_address_usage_metrics` | Control to enable/disable network address usage metrics in the VPC. | `True` | bool |
| `vpc_tags` | Additional tags for the VPC. | `{}` | ${map(string)} |
| `igw_enabled` | Control to deploy internet gateway. | `True` | bool |
| `igw_tags` | Additional tags for the internet gateway. | `{}` | ${map(string)} |
| `subnets_azs_names` | (Optional) The names of the Availability Zones to use for the subnets.
If not provided, the Availability Zones will be automatically selected. | `[]` | ${list(string)} |
| `subnets_ipv4_cidr_newbits` | The number of newbits to add to the CIDR block for the subnets. | `4` | number |
| `subnets_tags` | Additional tags for the subnets. | `{}` | ${map(string)} |
| `subnets_public_enabled` | Control to deploy public subnets. | `True` | bool |
| `subnets_public_enable_dns64` | Control to enable/disable DNS64 for the public subnets. | `False` | bool |
| `subnets_public_map_public_ip_on_launch` | Control to map public IP on launch for the public subnets. | `False` | bool |
| `subnets_public_enable_resource_name_dns_a_record_on_launch` | Control to enable/disable resource name DNS A record on launch for the public subnets. | `False` | bool |
| `subnets_public_enable_resource_name_dns_aaaa_record_on_launch` | Control to enable/disable resource name DNS AAAA record on launch for the public subnets. | `False` | bool |
| `subnets_public_assign_ipv6_address_on_creation` | Control to assign IPv6 address on creation for the public subnets. | `False` | bool |
| `subnets_public_tags` | Additional tags for the public subnets. | `{}` | ${map(string)} |
| `subnets_private_enabled` | Control to deploy private subnets. | `True` | bool |
| `subnets_private_ipv4_cidr_offset` | The offset to add to the CIDR block for the private subnets. | `100` | number |
| `subnets_private_enable_dns64` | Control to enable/disable DNS64 for the private subnets. | `False` | bool |
| `subnets_private_dns_hostname_type` | The type of hostname to assign to the private subnets. | `ip-name` | string |
| `subnets_private_enable_resource_name_dns_a_record_on_launch` | Control to enable/disable resource name DNS A record on launch for the private subnets. | `False` | bool |
| `subnets_private_enable_resource_name_dns_aaaa_record_on_launch` | Control to enable/disable resource name DNS AAAA record on launch for the private subnets. | `False` | bool |
| `subnets_private_assign_ipv6_address_on_creation` | Control to assign IPv6 address on creation for the private subnets. | `False` | bool |
| `subnets_private_tags` | Additional tags for the private subnets. | `{}` | ${map(string)} |
| `rt_tags` | Additional tags for the route tables. | `{}` | ${map(string)} |
| `rt_public_enabled` | Control to deploy public route table. | `True` | bool |
| `rt_public_tags` | Additional tags for the public route table. | `{}` | ${map(string)} |
| `rt_private_enabled` | Control to deploy private route tables. | `True` | bool |
| `rt_private_tags` | Additional tags for the private route tables. | `{}` | ${map(string)} |
| `eip_enabled` | Control to deploy elastic IPs. | `True` | bool |
| `eip_tags` | Additional tags for the elastic IPs. | `{}` | ${map(string)} |
| `ngw_enabled` | Control to deploy NAT gateways. | `True` | bool |
| `ngw_count` | The number of NAT gateways to deploy. | `${var.azs_count}` | number |
| `ngw_connectivity_type` | The type of connectivity for the NAT gateway. | `private` | string |
| `ngw_tags` | Additional tags for the NAT gateways. | `{}` | ${map(string)} |
| `acl_tags` | Additional tags for the network ACLs. | `{}` | ${map(string)} |
| `acl_public_enabled` | Control to deploy public network ACL. | `True` | bool |
| `acl_public_ingress_rules` | Ingress rules for the public network ACL. | `[]` | ${list(object({"protocol": "string", "number": "number", "action": "string", "cidr_block": "string", "from_port": "number", "to_port": "number"}))} |
| `acl_public_egress_rules` | Egress rules for the public network ACL. | `[]` | ${list(object({"protocol": "string", "number": "number", "action": "string", "cidr_block": "string", "from_port": "number", "to_port": "number"}))} |
| `acl_public_tags` | Additional tags for the public network ACL. | `{}` | ${map(string)} |
| `acl_private_enabled` | Control to deploy private network ACLs. | `True` | bool |
| `acl_private_ingress_rules` | Ingress rules for the private network ACLs. | `[]` | ${list(object({"protocol": "string", "number": "number", "action": "string", "cidr_block": "string", "from_port": "number", "to_port": "number"}))} |
| `acl_private_egress_rules` | Egress rules for the private network ACLs. | `[]` | ${list(object({"rule_number": "number", "rule_protocol": "string", "rule_action": "string", "rule_cidr_block": "string", "rule_from_port": "number", "rule_to_port": "number"}))} |
| `acl_private_tags` | Additional tags for the private network ACLs. | `{}` | ${map(string)} |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | ID of the VPC. |
| `public_subnet_ids` | List of IDs of the public subnets. |
| `private_subnet_ids` | List of IDs of the private subnets. |
| `internet_gateway_id` | ID of the Internet Gateway. |
| `elastic_ip_ids` | List of IDs of the Elastic IPs. |
| `nat_gateway_ids` | List of NAT Gateway IDs. |
| `public_route_table_id` | ID of the public route table. |
| `private_route_table_ids` | List of private route table IDs. |
| `public_network_acl_id` | ID of the public network ACL. |
| `private_network_acl_ids` | List of private network ACL IDs. |
