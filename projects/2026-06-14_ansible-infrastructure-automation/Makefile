.PHONY: help install syntax check base web db monitor full clean test

help:
	@echo "Ansible Infrastructure Automation - Available commands:"
	@echo ""
	@echo "Setup:"
	@echo "  make install         - Install Ansible and dependencies"
	@echo ""
	@echo "Validation:"
	@echo "  make syntax          - Check playbook syntax"
	@echo "  make check           - Run in check mode (dry-run)"
	@echo ""
	@echo "Playbooks:"
	@echo "  make base            - Deploy base infrastructure"
	@echo "  make web             - Deploy web servers"
	@echo "  make db              - Deploy database"
	@echo "  make monitor         - Deploy monitoring"
	@echo "  make full            - Deploy everything"
	@echo ""
	@echo "Testing:"
	@echo "  make test            - Run connectivity tests"
	@echo "  make facts           - Gather facts from all hosts"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean           - Remove backup files"

install:
	pip install ansible

syntax:
	ansible-playbook --syntax-check playbooks/*.yml

check:
	ansible-playbook -C playbooks/01-base-setup.yml

base:
	ansible-playbook playbooks/01-base-setup.yml -v

web:
	ansible-playbook playbooks/02-deploy-web.yml -v

db:
	ansible-playbook playbooks/03-deploy-database.yml -v

monitor:
	ansible-playbook playbooks/04-deploy-monitoring.yml -v

full:
	ansible-playbook playbooks/00-full-stack.yml -v

test:
	ansible all -m ping
	ansible all -m setup -a "filter=ansible_os_family"

facts:
	ansible all -m setup

clean:
	find . -name "*.swp" -delete
	find . -name "*~" -delete
