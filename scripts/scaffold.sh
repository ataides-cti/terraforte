#!/bin/bash

PROVIDER=$1
CATEGORY=$2
NAME=$3

if [ -z "$PROVIDER" ] || [ -z "$CATEGORY" ] || [ -z "$NAME" ]; then
  echo "Usage: $0 <provider> <category> <module>"
  exit 1
fi

BASE_DIR="modules/$PROVIDER/$CATEGORY/$NAME"

echo "Creating module scaffold at $BASE_DIR..."

mkdir -p "$BASE_DIR"

touch "$BASE_DIR/outputs.tf"

cat > "$BASE_DIR/main.tf" <<EOF
locals {
  internal_tags = {
    ManagedBy      = "terraform"
    Source         = "terraforte"
    Version        = "0.1.0"
  }

  effective_tags = merge(
    { Name = var.name },
    local.internal_tags,
    var.tags,
  )
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
}

variable "tags" {
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
# $PROVIDER - $CATEGORY - $NAME

Module description.

## Inputs

| Name                  | Description                                            | Type            | Required  |
|-----------------------|--------------------------------------------------------|-----------------|-----------|
| name                  | Name to be used on all the resources as identifier.    | string          | true      |
| tags                  | Tags to apply to all resources.                        | map(string)     | false     |

## Outputs

| Name             | Description                    |
|------------------|--------------------------------|
| output_name      | Output description             |
EOF

cat > "$BASE_DIR/versions.tf" <<EOF
terraform {
  required_version = ">= 1.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}
EOF

cat > "$BASE_DIR/metadata.yaml" <<EOF
id: $PROVIDER-$CATEGORY-$NAME
owner: oss@ataides.com
lifecycle: draft
compliance:
  - soc-2
  - nist-800-53
  - iso-27001
last_reviewed: TBD
EOF

echo "Module scaffold created at $BASE_DIR"
