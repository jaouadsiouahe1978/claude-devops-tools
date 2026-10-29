.PHONY: help deploy undeploy status logs connect backup restore clean test port-forward

NAMESPACE ?= postgres-demo
POD_NAME ?= postgres-0
BACKUP_DIR ?= ./backups

help:
	@echo "PostgreSQL StatefulSet Kubernetes - Makefile"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  deploy         - Deploy PostgreSQL"
	@echo "  undeploy       - Remove PostgreSQL"
	@echo "  status         - Show cluster status"
	@echo "  logs           - Show pod logs"
	@echo "  port-forward   - Enable port forwarding"
	@echo "  connect        - Connect to PostgreSQL"
	@echo "  backup         - Backup the database"
	@echo "  restore        - Restore from backup"
	@echo "  test           - Run tests"
	@echo "  clean          - Cleanup everything"
	@echo ""
	@echo "Variables:"
	@echo "  NAMESPACE=     (default: postgres-demo)"
	@echo "  POD_NAME=      (default: postgres-0)"
	@echo ""
	@echo "Examples:"
	@echo "  make deploy"
	@echo "  make deploy NAMESPACE=custom-ns"
	@echo "  make logs POD_NAME=postgres-1"

deploy:
	@echo "🚀 Deploying PostgreSQL..."
	bash scripts/deploy.sh $(NAMESPACE) deploy

undeploy:
	@echo "🗑️  Removing PostgreSQL..."
	bash scripts/deploy.sh $(NAMESPACE) undeploy

status:
	@echo "📊 Cluster status..."
	bash scripts/deploy.sh $(NAMESPACE) status

logs:
	@echo "📝 Streaming logs..."
	bash scripts/deploy.sh $(NAMESPACE) logs

port-forward:
	@echo "🌉 Starting port forward..."
	bash scripts/deploy.sh $(NAMESPACE) port-forward

connect:
	@echo "🔗 Connecting to PostgreSQL..."
	bash scripts/connect.sh $(NAMESPACE) $(POD_NAME)

backup:
	@echo "📦 Creating backup..."
	mkdir -p $(BACKUP_DIR)
	bash scripts/backup-postgres.sh $(NAMESPACE) $(POD_NAME)

restore:
	@echo "🔄 Restoring from backup..."
	bash scripts/restore-postgres.sh $(NAMESPACE) $(POD_NAME)

test:
	@echo "🧪 Running tests..."
	@echo "Checking pod status..."
	kubectl get pod $(POD_NAME) -n $(NAMESPACE)
	@echo ""
	@echo "Checking readiness..."
	kubectl exec -it $(POD_NAME) -n $(NAMESPACE) -- pg_isready -U postgres
	@echo ""
	@echo "Listing databases..."
	kubectl exec -it $(POD_NAME) -n $(NAMESPACE) -- psql -U postgres -l
	@echo ""
	@echo "✅ Basic tests passed!"

clean:
	@echo "🧹 Cleaning up..."
	bash scripts/deploy.sh $(NAMESPACE) undeploy
	@echo "Removing backup directory..."
	rm -rf $(BACKUP_DIR)
	@echo "✅ Cleanup complete!"

# Development targets
dev-local:
	@echo "🐳 Starting PostgreSQL locally with Docker Compose..."
	docker-compose up -d
	@echo "PostgreSQL is ready at localhost:5432"
	@echo "Use: psql -h localhost -U postgres"

dev-local-stop:
	@echo "🛑 Stopping local PostgreSQL..."
	docker-compose down

dev-logs:
	docker-compose logs -f postgres

# Kubernetes debugging targets
debug-events:
	@echo "📋 Recent Kubernetes events..."
	kubectl get events -n $(NAMESPACE) --sort-by='.lastTimestamp' | tail -20

debug-describe:
	@echo "📋 Pod description..."
	kubectl describe pod $(POD_NAME) -n $(NAMESPACE)

debug-pvc:
	@echo "💾 PersistentVolumeClaim status..."
	kubectl get pvc -n $(NAMESPACE)
	kubectl describe pvc data-$(POD_NAME) -n $(NAMESPACE) || true

# Advanced targets
ha-setup:
	@echo "🔧 Setting up Patroni HA (advanced)..."
	@echo "See advanced/ADVANCED.md for details"
	@echo "helm install etcd bitnami/etcd -n $(NAMESPACE)"

pgbouncer:
	@echo "🔧 Setting up pgBouncer (advanced)..."
	@echo "See advanced/ADVANCED.md for details"

.DEFAULT_GOAL := help
