.PHONY: help install test test-local lint check dry-run run clean

help:
	@echo "Ansible Server Hardening - Available Commands"
	@echo ""
	@echo "  make install      - Install Ansible and dependencies"
	@echo "  make lint         - Check syntax of playbooks and roles"
	@echo "  make check        - Dry-run without making changes"
	@echo "  make test-local   - Test with Docker containers locally"
	@echo "  make run          - Run the full playbook on real servers"
	@echo "  make clean        - Clean up temporary files and Docker containers"
	@echo ""

install:
	pip install ansible jinja2 pyyaml

lint:
	@echo "Checking syntax..."
	ansible-playbook site.yml --syntax-check
	ansible-playbook webservers.yml --syntax-check
	ansible-playbook test-playbook.yml --syntax-check
	@echo "✓ Syntax check passed"

check:
	@echo "Running dry-run (check mode)..."
	ansible-playbook site.yml -i inventory/hosts --check -v

test-local:
	@bash test-local.sh

run:
	@echo "Running full playbook..."
	ansible-playbook site.yml -i inventory/hosts -v

run-webservers:
	@echo "Running webserver playbook..."
	ansible-playbook webservers.yml -i inventory/hosts -v

test:
	@echo "Running validation tests..."
	ansible-playbook test-playbook.yml -i inventory/hosts -v

ping:
	@echo "Testing connectivity..."
	ansible -i inventory/hosts all -m ping

facts:
	@echo "Gathering facts..."
	ansible -i inventory/hosts all -m setup

clean-docker:
	@echo "Cleaning up Docker containers..."
	docker-compose -f docker-compose-test.yml down || true

clean: clean-docker
	@echo "Cleaning temporary files..."
	rm -rf *.retry
	find . -type d -name __pycache__ -exec rm -rf {} +
	@echo "✓ Cleanup complete"

.DEFAULT_GOAL := help
