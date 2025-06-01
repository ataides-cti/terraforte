# Contributing to TerraForte

Thank you for considering contributing! This project aims to provide a high-quality, secure-by-default set of Terraform modules with **built-in compliance** and strong **governance metadata**. To maintain this standard, we follow a few important guidelines.

## Prerequisites

Before contributing, please ensure you have:

- Terraform v1.12+ installed
- `python-hcl2` installed
- `tflint`, `checkov`, and `opa` installed
- Pre-commit set up (`pre-commit install`)
- Familiarity with basic Git workflows

## Contributing a New Module

1. Fork the repository and create a branch:  
   
```bash
git checkout -b feat/my-new-module
```

2. Run the make command to create a scaffold folder:

```bash
make scaffold PROVIDER=provider NAME=name 
```

3.	After making your changes, validate and test:

```bash
terraform init && terraform validate
tflint
checkov -d .
```

4.	Commit and push your changes:

```bash
git commit -m "feat(module): add your-module-name"
```

5.	Open a pull request with a clear description and link to any related issue.

### metadata.yaml Template

Each module must include a metadata.yaml file like the following:

```bash
id: aws-s3-secure
owner: oss@ataides.com
lifecycle: stable
compliance:
  - cis-aws-1.3
  - iso27001-9.2
  - lgpd-ready
last_reviewed: 2025-05-30
```

This is used for compliance tracking, automation, and governance reporting.

## Contributing Tests or Fixes

Bug reports, hardening improvements, or compliance updates are welcome.

Please:

- Keep PRs atomic and focused.
- Reference any affected module(s) in the PR title.
- Update CHANGELOG.md when making user-facing changes.
- Ensure all checks pass in CI before requesting review.

## Code Standards

- Follow Terraform Style Guide.
- Format code with terraform fmt -recursive.
- Use semantic versioning in your commits: feat, fix, chore, docs, refactor, etc.
- Use pre-commit to auto-run linters and formatters before committing.

## Security Disclosure

If you discover a potential security issue, please do not open a public issue.
Instead, email us at `security@ataides.com` following the process in (SECURITY.md)[./SECURITY.md]

# Thank You

Whether you’re fixing a typo, improving a module, or leading an initiative, your contribution matters. This project is powered by community expertise and the pursuit of operational excellence.

— With gratitude, TerraForte Maintainers
