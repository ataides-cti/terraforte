TERRAFORM ?= terraform
TFLINT ?= tflint
CHECKOV ?= checkov

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
	$(TFLINT) --recursive $(MODULE_PATH)

# Validate Terraform code
validate:
	@echo "Running terraform validate..."
	cd $(MODULE_PATH) && $(TERRAFORM) init -backend=false && $(TERRAFORM) validate

# Run security checks
security:
	@echo "Running Checkov..."
	$(CHECKOV) -d $(MODULE_PATH)

# Run all local checks
check: fmt lint validate security

# Clean up .terraform folders
clean:
	@echo "Cleaning up .terraform directories..."
	find . -type d -name ".terraform" -exec rm -rf {} +

# Help
help:
	@echo ""
	@echo "Available commands:"
	@echo "  make fmt            - Format Terraform files"
	@echo "  make lint           - Run TFLint on selected module"
	@echo "  make validate       - Validate selected module"
	@echo "  make security       - Run Checkov on selected module"
	@echo "  make check          - Run all local validations"
	@echo "  make clean          - Remove .terraform folders"
	@echo "  make PROVIDER=name  - Target a specific provider (default: aws)"
	@echo ""
