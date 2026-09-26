#!/bin/sh
# PostgreSQL Replication Monitoring Script

# Install required tools
apk add --no-cache postgresql-client

echo "=== PostgreSQL Replication Monitor Started ==="
echo "Monitoring primary and standby replication status..."
echo ""

# Function to check replication status
check_replication() {
  echo "=== Replication Status Check - $(date '+%Y-%m-%d %H:%M:%S') ==="

  # Check if primary is running
  if pg_isready -h pg_primary -p 5432 -U postgres >/dev/null 2>&1; then
    echo "✓ Primary (pg_primary:5432) is UP"

    # Get replication status from primary
    echo ""
    echo "--- Replication Status on Primary ---"
    PGPASSWORD=postgres_password psql -h pg_primary -U postgres -d postgres \
      -c "SELECT pid, usename, application_name, state, sync_state, write_lag, flush_lag, replay_lag FROM pg_stat_replication;" 2>/dev/null || \
      echo "⚠ Could not connect to primary"

    # Check WAL info
    echo ""
    echo "--- WAL Info on Primary ---"
    PGPASSWORD=postgres_password psql -h pg_primary -U postgres -d postgres \
      -c "SELECT pg_current_wal_lsn() as current_wal_lsn;" 2>/dev/null || \
      echo "⚠ Could not fetch WAL info"

  else
    echo "✗ Primary (pg_primary:5432) is DOWN"
  fi

  # Check if standby is running
  if pg_isready -h pg_standby -p 5432 -U replicator >/dev/null 2>&1; then
    echo ""
    echo "✓ Standby (pg_standby:5432) is UP"

    # Check if standby is in recovery
    echo ""
    echo "--- Standby Status ---"
    PGPASSWORD=repl_password psql -h pg_standby -U replicator -d postgres \
      -c "SELECT pg_is_in_recovery() as in_recovery, pg_last_wal_receive_lsn() as last_received_lsn;" 2>/dev/null || \
      echo "⚠ Could not connect to standby"

    # Try to read test data from standby
    echo ""
    echo "--- Test Data on Standby (Read-Only) ---"
    PGPASSWORD=repl_password psql -h pg_standby -U replicator -d testdb \
      -c "SELECT * FROM test_replication ORDER BY id DESC LIMIT 3;" 2>/dev/null || \
      echo "⚠ Could not fetch test data from standby"

  else
    echo "✗ Standby (pg_standby:5432) is DOWN"
  fi

  echo ""
  echo "================================================"
  echo ""
}

# Main monitoring loop
while true; do
  check_replication
  sleep 15
done
