.PHONY: help setup up down logs clean check test renew

help:
	@echo "Let's Encrypt & Certbot Automation - Available Commands"
	@echo ""
	@echo "  make setup          - Initial setup (create directories, .env file)"
	@echo "  make up             - Start all services"
	@echo "  make down           - Stop all services"
	@echo "  make logs           - Show logs from all services"
	@echo "  make check          - Check certificate status and expiry dates"
	@echo "  make test           - Test certificate renewal (dry-run)"
	@echo "  make renew          - Force certificate renewal"
	@echo "  make clean          - Remove all services and certificates"
	@echo "  make restart        - Restart all services"
	@echo "  make nginx-test     - Test nginx configuration"
	@echo ""

setup:
	@echo "Creating directories..."
	mkdir -p certs certbot/www
	@echo "Creating .env file..."
	@if [ ! -f .env ]; then cp .env.example .env; echo "Created .env - please edit with your domain"; fi
	@echo "Setup complete!"

up:
	docker-compose up -d
	@echo "Services started. Check status with: make logs"

down:
	docker-compose down

logs:
	docker-compose logs -f

logs-nginx:
	docker-compose logs -f nginx

logs-certbot:
	docker-compose logs -f certbot

logs-monitoring:
	docker-compose logs -f monitoring

check:
	docker-compose exec monitoring /check-certs.sh

test:
	docker-compose exec certbot certbot renew --dry-run --quiet
	@echo "Dry-run test completed. Check logs with: make logs-certbot"

renew:
	docker-compose exec certbot certbot renew --force-renewal --quiet
	@echo "Certificate renewal initiated. Check logs with: make logs-certbot"

nginx-test:
	docker-compose exec nginx nginx -t

restart:
	docker-compose restart

restart-nginx:
	docker-compose restart nginx

restart-certbot:
	docker-compose restart certbot

clean:
	docker-compose down -v
	rm -rf certs/
	rm -f .env
	@echo "Cleanup complete"

ps:
	docker-compose ps

shell-nginx:
	docker-compose exec nginx sh

shell-certbot:
	docker-compose exec certbot bash

shell-monitoring:
	docker-compose exec monitoring bash

cert-info:
	@echo "Certificate Information:"
	@docker-compose exec certbot ls -la /etc/letsencrypt/live/ 2>/dev/null || echo "No certificates found"

cert-expiry:
	@echo "Certificate Expiry Dates:"
	@for cert in ./certs/live/*/cert.pem; do \
		if [ -f "$$cert" ]; then \
			domain=$$(dirname $$cert | xargs basename); \
			expiry=$$(docker run --rm -v ./certs:/certs alpine/openssl x509 -in /certs/live/$$domain/cert.pem -noout -enddate 2>/dev/null | cut -d= -f2); \
			echo "  $$domain: $$expiry"; \
		fi \
	done

.DEFAULT_GOAL := help
