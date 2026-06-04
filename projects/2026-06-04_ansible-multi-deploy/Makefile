.PHONY: help syntax check dry-run deploy deploy-web deploy-monitoring ping inventory lint clean

help:
	@echo "Ansible Multi-Server Deployment"
	@echo "=================================="
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  syntax         - Check playbook syntax"
	@echo "  check          - Lint playbooks"
	@echo "  ping           - Test connectivity to all hosts"
	@echo "  inventory      - List all hosts"
	@echo "  dry-run        - Run playbook in check mode (no changes)"
	@echo "  deploy         - Full deployment (all roles)"
	@echo "  deploy-web     - Web servers only"
	@echo "  deploy-mon     - Monitoring only"
	@echo "  verbose        - Deploy with verbose output"
	@echo "  clean          - Clean temporary files and logs"
	@echo ""

syntax:
	ansible-playbook --syntax-check site.yml

check:
	ansible-lint site.yml || true

ping:
	ansible all -i inventories/production.ini -m ping

inventory:
	ansible-inventory -i inventories/production.ini --list

dry-run:
	ansible-playbook -i inventories/production.ini site.yml --check

deploy:
	ansible-playbook -i inventories/production.ini site.yml

deploy-web:
	ansible-playbook -i inventories/production.ini web_deploy.yml

deploy-mon:
	ansible-playbook -i inventories/production.ini monitoring_setup.yml

verbose:
	ansible-playbook -i inventories/production.ini site.yml -vvv

clean:
	rm -f ansible.log
	rm -rf /tmp/ansible_facts
	find . -name "*.pyc" -delete
	find . -name "__pycache__" -delete
