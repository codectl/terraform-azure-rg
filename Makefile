.PHONY: all validate fmt docs check test test-parallel test-sequential test-local test-unit

all: validate fmt docs

TEST_ARGS := $(if $(skip-destroy),-skip-destroy=$(skip-destroy)) \
             $(if $(exception),-exception=$(exception)) \
             $(if $(example),-example=$(example)) \
             $(if $(local),-local=$(local))

test:
	cd tests && go test -v -timeout 60m -run '^TestApplyNoError$$' -args $(TEST_ARGS) .

test-sequential:
	cd tests && go test -v -timeout 60m -run '^TestApplyAllSequential$$' -args $(TEST_ARGS) .

test-parallel:
	cd tests && go test -v -timeout 60m -run '^TestApplyAllParallel$$' -args $(TEST_ARGS) .

test-local:
	cd tests && go test -v -timeout 60m -run '^TestApplyAllLocal$$' -args $(TEST_ARGS) .

test-unit:
	@if [ -n "$(file)" ] && [ ! -f "$(file)" ]; then \
		echo "test-unit: no such test file: $(file)"; exit 1; \
	fi
	terraform init -backend=false
	terraform test $(if $(file),-filter=$(file)) $(if $(verbose),-verbose)
	@echo "Cleaning up initialization files..."
	rm -rf .terraform terraform.tfstate terraform.tfstate.backup .terraform.lock.hcl

docs:
	go run github.com/codectl/shapr/cmd/shapr@latest generate .

check:
	go run github.com/codectl/shapr/cmd/shapr@latest check -schema .

fmt:
	terraform fmt -recursive

validate:
	terraform init -backend=false
	terraform validate
	@echo "Cleaning up initialization files..."
	rm -rf .terraform terraform.tfstate terraform.tfstate.backup .terraform.lock.hcl
