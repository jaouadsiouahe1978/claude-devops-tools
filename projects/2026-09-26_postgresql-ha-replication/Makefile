.PHONY: help up down logs test failover clean psql-primary psql-standby monitor

help:
	@echo "PostgreSQL High Availability - Streaming Replication"
	@echo ""
	@echo "Available targets:"
	@echo "  make up              - Start primary and standby"
	@echo "  make down            - Stop all services"
	@echo "  make logs            - Show logs from all containers"
	@echo "  make test            - Run replication tests"
	@echo "  make monitor         - Monitor replication status"
	@echo "  make failover        - Promote standby to primary"
	@echo "  make psql-primary    - Connect to primary with psql"
	@echo "  make psql-standby    - Connect to standby with psql"
	@echo "  make clean           - Clean up volumes and containers"
	@echo "  make status          - Show quick status of primary and standby"
	@echo "  make insert-data     - Insert test data on primary"
	@echo ""

up:
	@echo "Starting PostgreSQL HA Cluster..."
	docker-compose up -d
	@echo "Waiting for services to be ready..."
	sleep 5
	@echo "Cluster started!"
	@echo ""
	@echo "Connection strings:"
	@echo "  Primary:  postgresql://postgres:postgres_password@localhost:5432/testdb"
	@echo "  Standby:  postgresql://replicator:repl_password@localhost:5433/testdb (read-only)"

down:
	@echo "Stopping PostgreSQL HA Cluster..."
	docker-compose down

logs:
	@docker-compose logs -f

test:
	@echo "Running Replication Tests..."
	@bash test-replication.sh

failover:
	@echo "Starting Failover Procedure..."
	@bash failover.sh

monitor:
	@echo "Starting Replication Monitor..."
	@docker logs -f pg_monitor

psql-primary:
	@docker exec -it pg_primary psql -U postgres -d testdb

psql-standby:
	@docker exec -it pg_standby psql -U replicator -d testdb

clean:
	@echo "Cleaning up resources..."
	docker-compose down -v
	@echo "All containers and volumes removed"

status:
	@echo "=== Cluster Status ==="
	@if docker exec pg_primary pg_isready -U postgres >/dev/null 2>&1; then \
		echo "✓ Primary (pg_primary:5432) is UP"; \
	else \
		echo "✗ Primary (pg_primary:5432) is DOWN"; \
	fi
	@if docker exec pg_standby pg_isready -U replicator >/dev/null 2>&1; then \
		echo "✓ Standby (pg_standby:5433) is UP"; \
	else \
		echo "✗ Standby (pg_standby:5433) is DOWN"; \
	fi
	@echo ""
	@echo "=== Replication Status ==="
	@docker exec pg_primary psql -U postgres -d postgres \
		-c "SELECT COUNT(*) as connected_standbys FROM pg_stat_replication;" 2>/dev/null || \
		echo "Could not fetch replication status"

insert-data:
	@echo "Inserting test data on Primary..."
	@docker exec pg_primary psql -U postgres -d testdb \
		-c "INSERT INTO test_replication (message) VALUES ('Data inserted at $(shell date)'); SELECT COUNT(*) as total_rows FROM test_replication;"
	@echo ""
	@echo "Checking Standby replication (5 second delay)..."
	@sleep 5
	@docker exec pg_standby psql -U replicator -d testdb \
		-c "SELECT COUNT(*) as total_rows FROM test_replication;"
