# TerraForte - Infrastructure as Code with Compliance by Design

A curated collection of **opinionated, secure-by-default Terraform modules**. Each module is built for real-world cloud deployments, with **pre-validated compliance controls**, architectural best practices, and strict metadata for traceability.

Built for teams that value **security, predictability, and speed** in cloud infrastructure.

## Key Features

- **Compliance by Design**: Supports CIS Benchmarks, NIST, LGPD, ISO 27001 and custom policies.
- **Secure Defaults**: Encryption, logging, RBAC, IAM least privilege, and naming/tagging enforced.
- **Rich Metadata per Module**: `metadata.yaml` includes compliance tags, ownership, SLA, and lifecycle status.
- **CI/CD Friendly**: Integrated with `terraform validate`, `tflint`, `checkov`, and optional OPA policies.
- **Cloud Provider Support**: For AWS, GCP and Azure

## Getting Started

Install [Terraform](https://developer.hashicorp.com/terraform) and clone this repository:

```bash
git clone git@github.com:ataides-cti/terraforte.git
cd terraform/examples/aws/vpc-basic
terraform init
terraform plan
terraform apply
```

Each module includes a self-contained README.md and usage examples.

## Module Metadata (metadata.yaml)

Each module includes a metadata.yaml for governance and lifecycle tracking:

```bash
id: aws-vpc-secure
owner: oss@ataides.com
lifecycle: stable
compliance:
  - cis-aws-1.3
  - iso27001-9.1
  - lgpd-ready
last_reviewed: 2025-05-30
```

## Contributing

We welcome contributions from platform engineers, security architects, and cloud specialists.

Check out CONTRIBUTING.md to get started.

- Submit new modules via PR
- Follow semantic versioning (MAJOR.MINOR.PATCH)
- Include tests and metadata in every module

## License

This project is licensed under the Apache 2.0 License.

## Contact

Questions, ideas or feedback?
Open an issue or reach out via GitHub Discussions.
