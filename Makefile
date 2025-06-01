TERRAFORM ?= terraform
TFLINT ?= tflint
CHECKOV ?= checkov
PYTHON ?= python3
BASH ?= /bin/bash

# Default module (can be overridden with `make PROVIDER=provider-name`)
PROVIDER ?= aws
MODULE_PATH = modules/$(PROVIDER)

# Format all Terraform code
fmt:
	@echo "Running terraform fmt..."
	$(TERRAFORM) fmt -recursive

# Lint Terraform code
lint:
	@echo "Running tflint..."
	$(TFLINT) --chdir $(MODULE_PATH)/$(NAME)

# Validate Terraform code
validate:
	@echo "Running terraform validate..."
	cd $(MODULE_PATH)/$(NAME) && $(TERRAFORM) init -backend=false && $(TERRAFORM) validate

# Run security checks
security:
	@echo "Running Checkov..."
	$(CHECKOV) -d $(MODULE_PATH)/$(NAME)

# Clean up .terraform folders
clean:
	@echo "Cleaning up .terraform directories..."
	-find . -type d -name ".terraform" -exec rm -rf {} + || true
	-find . -type f -name ".terraform.lock.hcl" -delete || true

# Run all local checks
check: fmt lint validate security clean

# Scaffold a new module
scaffold:
	$(BASH) scripts/scaffold.sh $(MODULE_PATH)/$(NAME)

# Generate README.md from .tf files
readme:
	$(PYTHON) scripts/readme_from_tf.py $(MODULE_PATH)/$(NAME)

# Help
help:
	@echo ""
	@echo "Available commands:"
	@echo "  make fmt                       - Format Terraform files"
	@echo "  make lint NAME=module-name     - Run TFLint on selected module"
	@echo "  make validate NAME=module-name - Validate selected module"
	@echo "  make security NAME=module-name - Run Checkov on selected module"
	@echo "  make check NAME=module-name    - Run all local validations"
	@echo "  make clean                     - Remove .terraform folders"
	@echo "  make scaffold NAME=module-name - Create scaffold using script"
	@echo "  make readme NAME=module-name   - Generate README.md from variables.tf"
	@echo "\n"
	@echo "  PROVIDER=provider-name         - Target a specific provider (default: aws)"
	@echo ""
