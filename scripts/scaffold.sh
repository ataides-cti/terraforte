#!/bin/bash

PROVIDER=$1
NAME=$2

if [ -z "$PROVIDER" ] || [ -z "$NAME" ]; then
  echo "Usage: $0 <provider> <module>"
  exit 1
fi

BASE_DIR="modules/$PROVIDER/$NAME"

echo "Creating module scaffold at $BASE_DIR..."

mkdir -p "$BASE_DIR/examples" "$BASE_DIR/tests"

touch "$BASE_DIR/outputs.tf"

cat > "$BASE_DIR/main.tf" <<EOF
locals {
  internal_tags = {
    ManagedBy      = "terraform"
    Source         = "terraforte"
    Version        = "0.1.0"
  }
}

################################################################################
# Resource Name
################################################################################
EOF

cat > "$BASE_DIR/variables.tf" <<EOF
################################################################################
# General
################################################################################

variable "name" {
  type        = string
  description = "Name to be used on all the resources as identifier."
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
EOF

cat > "$BASE_DIR/README.md" <<EOF
# Terraforte - $PROVIDER - $NAME

A Terraform module to provision $NAME on $PROVIDER.

## Example

Here's a simple example of how to use this module:

\`\`\`hcl
module "name" {
  source = "terraforte/$PROVIDER/$NAME"

  name = "name"

  tags = {
    Owner       = "John Doe"
    Environment = "dev"
    Project     = "project-name"
    Tenant      = "tenant-name"
  }
}
\`\`\`

See the [examples folder](./examples/) for more working examples.

## Requirements

| Name | Version |
|------|---------|
| [Terraform](https://developer.hashicorp.com/terraform) | >= 1.12 |
| [$PROVIDER Provider](https://registry.terraform.io/browse/providers) | >= X.Y.Z |

## Inputs

| Name | Description | Type | Default | Nullable |
|------|-------------|------|---------|----------|
| name | Name to be used on all the resources as identifier. | string      | "terraforte" | false |
| tags | Tags to apply to all resources.                     | map(string) | {}          | true  |

## Outputs

| Name | Description |
|------|-------------|
| output_name | Output description |
EOF

cat > "$BASE_DIR/versions.tf" <<EOF
terraform {
  required_version = ">= 1.12"

  required_providers {
    $PROVIDER = {
      source  = "hashicorp/$PROVIDER"
      version = ">= X.Y.Z"
    }
  }
}
EOF

cat > "$BASE_DIR/metadata.yaml" <<EOF
id: terraforte-$PROVIDER-$NAME
owner: oss@ataides.com
lifecycle: draft
version: 0.1.0
last_reviewed: YYYY-MM-DD
EOF

echo "Module scaffold created at $BASE_DIR"
