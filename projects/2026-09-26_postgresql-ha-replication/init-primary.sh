#!/bin/bash
# Initialize PostgreSQL Primary for Streaming Replication

set -e

echo "=== Initializing PostgreSQL Primary ==="

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to start..."
until pg_isready -U postgres; do
  sleep 1
done

echo "PostgreSQL is ready!"

# Create replication user
echo "Creating replication user..."
psql -v ON_ERROR_STOP=1 -U postgres -c \
  "CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'repl_password';" || true

# Grant privileges to replication user
psql -v ON_ERROR_STOP=1 -U postgres -c \
  "ALTER DEFAULT PRIVILEGES FOR USER postgres IN SCHEMA public GRANT SELECT ON TABLES TO replicator;" || true

# Create test database and table
echo "Creating test database and table..."
psql -v ON_ERROR_STOP=1 -U postgres -c "CREATE DATABASE testdb;" || true

psql -v ON_ERROR_STOP=1 -U postgres -d testdb -c "
CREATE TABLE IF NOT EXISTS test_replication (
  id SERIAL PRIMARY KEY,
  message VARCHAR(255),
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
" || true

# Insert initial test data
psql -v ON_ERROR_STOP=1 -U postgres -d testdb -c \
  "INSERT INTO test_replication (message) VALUES ('Primary initialized at ' || now());" || true

# Grant permissions to public
psql -v ON_ERROR_STOP=1 -U postgres -d testdb -c "
GRANT CONNECT ON DATABASE testdb TO replicator;
GRANT USAGE ON SCHEMA public TO replicator;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO replicator;
" || true

echo "=== Primary initialization complete ==="
echo "Replication user created: replicator / repl_password"
echo "Test database created: testdb"
echo "Test table created: test_replication"
