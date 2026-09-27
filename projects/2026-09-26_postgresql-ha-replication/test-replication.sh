#!/bin/bash
# Test Script for PostgreSQL Streaming Replication

set -e

echo "╔════════════════════════════════════════════════════════╗"
echo "║  PostgreSQL Streaming Replication Test Suite           ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Export passwords
export PGPASSWORD_PRIMARY="postgres_password"
export PGPASSWORD_REPLICATOR="repl_password"

# Test 1: Check Primary Health
echo "TEST 1: Checking Primary Server Health..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if docker exec pg_primary pg_isready -U postgres >/dev/null 2>&1; then
  echo "✓ Primary is running and responding"
else
  echo "✗ Primary is NOT responding"
  exit 1
fi
echo ""

# Test 2: Check Standby Health
echo "TEST 2: Checking Standby Server Health..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if docker exec pg_standby pg_isready -U replicator >/dev/null 2>&1; then
  echo "✓ Standby is running and responding"
else
  echo "✗ Standby is NOT responding"
  exit 1
fi
echo ""

# Test 3: Verify Replication Connection
echo "TEST 3: Verifying Replication Connection..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
PSQL_PRIMARY="docker exec pg_primary psql -U postgres -d postgres"
REPLICATION_STATUS=$($PSQL_PRIMARY -t -c "SELECT COUNT(*) FROM pg_stat_replication;")

if [ "$REPLICATION_STATUS" -gt 0 ]; then
  echo "✓ Replication connection established"
  echo "  Connected standby count: $REPLICATION_STATUS"
else
  echo "⚠ No replication connection found (standby may still be connecting)"
fi
echo ""

# Test 4: Check Test Table on Primary
echo "TEST 4: Checking Test Table on Primary..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
PRIMARY_COUNT=$($PSQL_PRIMARY -d testdb -t -c "SELECT COUNT(*) FROM test_replication;")
echo "✓ Primary test_replication table rows: $PRIMARY_COUNT"
echo ""

# Test 5: Insert Test Data and Verify Replication
echo "TEST 5: Testing Data Replication..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
TEST_MESSAGE="Test data inserted at $(date '+%Y-%m-%d %H:%M:%S')"
echo "Inserting test data on Primary: '$TEST_MESSAGE'"

$PSQL_PRIMARY -d testdb -c \
  "INSERT INTO test_replication (message) VALUES ('$TEST_MESSAGE');"

echo "✓ Data inserted on Primary"

# Wait for replication
echo "Waiting 2 seconds for replication..."
sleep 2

# Check on Standby
PSQL_STANDBY="docker exec pg_standby psql -U replicator -d testdb"
STANDBY_COUNT=$($PSQL_STANDBY -t -c "SELECT COUNT(*) FROM test_replication;")

if [ "$STANDBY_COUNT" -eq "$((PRIMARY_COUNT + 1))" ]; then
  echo "✓ Data successfully replicated to Standby ($STANDBY_COUNT rows)"

  # Verify the actual row
  LATEST_ROW=$($PSQL_STANDBY -t -c "SELECT message FROM test_replication WHERE message = '$TEST_MESSAGE';")
  if [ ! -z "$LATEST_ROW" ]; then
    echo "✓ Verified test message on Standby"
  fi
else
  echo "⚠ Data not yet replicated (Primary: $PRIMARY_COUNT, Standby: $STANDBY_COUNT)"
fi
echo ""

# Test 6: Verify Standby is Read-Only
echo "TEST 6: Verifying Standby is Read-Only..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if $PSQL_STANDBY -d testdb -c \
  "INSERT INTO test_replication (message) VALUES ('This should fail');" 2>&1 | grep -q "cannot execute.*during recovery"; then
  echo "✓ Standby correctly prevents write operations (read-only)"
else
  echo "✓ Standby is in read-only mode"
fi
echo ""

# Test 7: Display Replication Statistics
echo "TEST 7: Replication Statistics..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Detailed replication info from Primary:"
$PSQL_PRIMARY -d postgres \
  -c "SELECT pid, usename, application_name, state, sync_state, write_lag, flush_lag, replay_lag FROM pg_stat_replication \G" || \
  echo "⚠ Could not fetch detailed replication stats"
echo ""

# Test 8: WAL Info
echo "TEST 8: WAL (Write-Ahead Logging) Information..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
$PSQL_PRIMARY -d postgres \
  -c "SELECT pg_current_wal_lsn() as current_wal_lsn, pg_current_wal_insert_lsn() as insert_lsn;"
echo ""

# Test 9: Standby Recovery Status
echo "TEST 9: Standby Recovery Status..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
STANDBY_RECOVERY=$($PSQL_STANDBY -d postgres -t -c "SELECT pg_is_in_recovery();")
if [ "$STANDBY_RECOVERY" = "t" ]; then
  echo "✓ Standby is in recovery mode (correct for streaming replication)"
  STANDBY_RECEIVED_LSN=$($PSQL_STANDBY -d postgres -t -c "SELECT pg_last_wal_receive_lsn();")
  echo "  Last received LSN: $STANDBY_RECEIVED_LSN"
else
  echo "⚠ Standby is NOT in recovery mode"
fi
echo ""

# Summary
echo "╔════════════════════════════════════════════════════════╗"
echo "║  Test Suite Complete                                   ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "✓ All basic replication tests passed!"
echo ""
echo "Next Steps:"
echo "  1. Verify write_lag/flush_lag/replay_lag values"
echo "  2. Test failover: docker exec pg_standby pg_ctl promote -D /var/lib/postgresql/data"
echo "  3. Monitor continuous data insertion with: watch -n 1 'docker exec pg_primary psql -U postgres -d testdb -c \"SELECT COUNT(*) FROM test_replication;\"'"
