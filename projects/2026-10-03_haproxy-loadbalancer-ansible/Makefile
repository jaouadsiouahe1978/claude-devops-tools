.PHONY: help syntax check dry-run deploy test stats health

help:
	@echo "HAProxy Load Balancer Ansible Playbook"
	@echo "======================================"
	@echo "Available targets:"
	@echo "  make syntax   - Check playbook syntax"
	@echo "  make check    - Perform a dry-run"
	@echo "  make deploy   - Deploy the infrastructure"
	@echo "  make test     - Test the load balancer"
	@echo "  make stats    - Show HAProxy statistics"
	@echo "  make health   - Check backend health"
	@echo "  make clean    - Remove temporary files"

syntax:
	ansible-playbook -i inventory/hosts.ini site.yml --syntax-check

check:
	ansible-playbook -i inventory/hosts.ini site.yml --check

deploy:
	ansible-playbook -i inventory/hosts.ini site.yml

test:
	@echo "Testing load balancer..."
	@for i in {1..10}; do \
		curl -s http://$(shell grep "lb-server" inventory/hosts.ini | awk '{print $$NF}' | cut -d= -f2)/ | head -1; \
	done

stats:
	@LB_IP=$$(grep -A0 "lb-server" inventory/hosts.ini | grep ansible_host | awk -F= '{print $$2}'); \
	echo "HAProxy Stats: http://$$LB_IP:8404/stats"; \
	echo "Username: admin"; \
	echo "Password: securepassword123"

health:
	@echo "Checking backend health..."
	@for host in $$(grep "ansible_host" inventory/hosts.ini | grep -v "lb-server" | awk -F= '{print $$2}'); do \
		echo "Testing $$host:8080/health"; \
		curl -s http://$$host:8080/health; \
	done

clean:
	find . -name "*.pyc" -delete
	find . -name "__pycache__" -type d -delete
	rm -rf .cache/
