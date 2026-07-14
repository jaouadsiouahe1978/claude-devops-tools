.PHONY: help install syntax-check check ping deploy test-common test-webserver test-database clean docker-up docker-down

help:
	@echo "Ansible Multi-Server Configuration Management"
	@echo ""
	@echo "Available commands:"
	@echo "  make install              - Install Ansible and dependencies"
	@echo "  make syntax-check         - Check playbook syntax"
	@echo "  make check                - Dry-run deployment"
	@echo "  make ping                 - Test connectivity to all hosts"
	@echo "  make deploy               - Deploy full configuration"
	@echo "  make test-common          - Deploy only common role"
	@echo "  make test-webserver       - Deploy only webserver role"
	@echo "  make test-database        - Deploy only database role"
	@echo "  make docker-up            - Start Docker test environment"
	@echo "  make docker-down          - Stop Docker test environment"
	@echo "  make clean                - Clean up temporary files"

install:
	pip install ansible>=2.9
	ansible-galaxy install -r requirements.yml

syntax-check:
	ansible-playbook playbook.yml --syntax-check

check:
	ansible-playbook -i inventory/production.ini playbook.yml --check -v

ping:
	ansible all -i inventory/production.ini -m ping

deploy:
	@echo "Deploying to production..."
	ansible-playbook -i inventory/production.ini playbook.yml -v

test-common:
	ansible-playbook -i inventory/production.ini playbook.yml --tags common -v

test-webserver:
	ansible-playbook -i inventory/production.ini playbook.yml --tags webserver -v

test-database:
	ansible-playbook -i inventory/production.ini playbook.yml --tags database -v

docker-up:
	docker-compose up -d
	@echo "Waiting for containers to be ready..."
	sleep 5
	@docker-compose exec -T server1 apt-get update > /dev/null 2>&1
	@docker-compose exec -T server2 apt-get update > /dev/null 2>&1
	@docker-compose exec -T server3 apt-get update > /dev/null 2>&1
	docker-compose ps

docker-down:
	docker-compose down

docker-test: docker-up
	@echo "Testing Ansible on Docker containers..."
	ansible -i inventory/dev.ini webservers -m ping
	ansible -i inventory/dev.ini databases -m ping

clean:
	rm -rf .ansible/facts
	find . -name "*.pyc" -delete
	find . -name "__pycache__" -type d -delete
	rm -rf .molecule
