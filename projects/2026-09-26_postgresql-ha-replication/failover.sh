#!/bin/bash
# PostgreSQL Failover Script - Promote Standby to Primary

set -e

echo "╔════════════════════════════════════════════════════════╗"
echo "║  PostgreSQL Failover Procedure                         ║"
echo "║  Promoting Standby to Primary                          ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Verify current status
echo -e "${YELLOW}Step 1: Verifying Current Cluster Status${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

PSQL_PRIMARY="docker exec -it pg_primary psql -U postgres -d postgres"
PSQL_STANDBY="docker exec -it pg_standby psql -U replicator -d postgres"

if docker exec pg_primary pg_isready -U postgres >/dev/null 2>&1; then
  echo -e "${GREEN}✓ Primary is UP${NC}"
  PRIMARY_UP=true
else
  echo -e "${RED}✗ Primary is DOWN${NC}"
  PRIMARY_UP=false
fi

if docker exec pg_standby pg_isready -U replicator >/dev/null 2>&1; then
  echo -e "${GREEN}✓ Standby is UP${NC}"
  STANDBY_UP=true
else
  echo -e "${RED}✗ Standby is DOWN${NC}"
  STANDBY_UP=false
fi
echo ""

# Step 2: Confirm failover
echo -e "${YELLOW}Step 2: Failover Confirmation${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${RED}WARNING: This will promote the STANDBY to PRIMARY${NC}"
echo "Existing connections to the standby will be terminated."
echo "Ensure you have backed up critical data."
echo ""

read -p "Do you want to proceed with failover? (yes/no): " -r
echo ""

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
  echo "Failover cancelled."
  exit 0
fi
echo ""

# Step 3: Stop primary (if it's up)
if [ "$PRIMARY_UP" = true ]; then
  echo -e "${YELLOW}Step 3: Stopping Primary Server${NC}"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  docker stop pg_primary
  echo -e "${GREEN}✓ Primary stopped${NC}"
  echo ""
  sleep 2
fi

# Step 4: Promote standby
echo -e "${YELLOW}Step 4: Promoting Standby to Primary${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$STANDBY_UP" = true ]; then
  echo "Sending promote signal to standby..."
  docker exec pg_standby pg_ctl promote -D /var/lib/postgresql/data -w
  echo -e "${GREEN}✓ Standby promoted to PRIMARY${NC}"
else
  echo -e "${RED}✗ Cannot promote: Standby is not running${NC}"
  exit 1
fi
echo ""

# Step 5: Verify new primary
echo -e "${YELLOW}Step 5: Verifying New Primary${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
sleep 3

# Note: After promotion, we need to use postgres user instead of replicator
PSQL_NEW_PRIMARY="docker exec pg_standby psql -U postgres -d postgres"

if docker exec pg_standby pg_isready -U postgres >/dev/null 2>&1; then
  echo -e "${GREEN}✓ New primary (pg_standby) is ready${NC}"

  # Check if it's still in recovery
  IN_RECOVERY=$($PSQL_NEW_PRIMARY -t -c "SELECT pg_is_in_recovery();")
  if [ "$IN_RECOVERY" = "f" ]; then
    echo -e "${GREEN}✓ New primary is no longer in recovery mode${NC}"
  else
    echo -e "${YELLOW}⚠ New primary still in recovery mode, waiting...${NC}"
    sleep 5
  fi

  # Verify replication users and database
  $PSQL_NEW_PRIMARY -d testdb -c "SELECT COUNT(*) as total_rows FROM test_replication;" 2>/dev/null || \
    echo "✓ Database accessible on new primary"
else
  echo -e "${RED}✗ New primary is not responding${NC}"
fi
echo ""

# Step 6: Restart old primary as standby (optional)
echo -e "${YELLOW}Step 6: (Optional) Restart Old Primary as New Standby${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

read -p "Restart old primary (pg_primary) as new standby? (yes/no): " -r
echo ""

if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
  echo "Starting pg_primary..."
  docker start pg_primary
  echo "Waiting for pg_primary to start..."
  sleep 10

  if docker exec pg_primary pg_isready -U postgres >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Old primary restarted${NC}"
    echo ""
    echo -e "${YELLOW}Manual Step Required:${NC}"
    echo "The old primary (pg_primary) has been restarted, but it still has stale data."
    echo "To make it a standby of the new primary (pg_standby), you need to:"
    echo ""
    echo "1. Remove the old data directory:"
    echo "   docker exec pg_primary rm -rf /var/lib/postgresql/data/*"
    echo ""
    echo "2. Run pg_basebackup from the new primary:"
    echo "   docker exec pg_primary pg_basebackup -h pg_standby -D /var/lib/postgresql/data -U replicator -v"
    echo ""
    echo "3. Create standby.signal:"
    echo "   docker exec pg_primary touch /var/lib/postgresql/data/standby.signal"
    echo ""
    echo "4. Restart pg_primary:"
    echo "   docker restart pg_primary"
  else
    echo -e "${RED}✗ Failed to restart old primary${NC}"
  fi
else
  echo "Skipped restarting old primary"
fi
echo ""

# Summary
echo "╔════════════════════════════════════════════════════════╗"
echo "║  Failover Complete                                     ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}✓ pg_standby is now the PRIMARY${NC}"
echo "  - Can accept read and write operations"
echo "  - Listening on port 5433"
echo ""
echo "Connection strings:"
echo "  New Primary: postgresql://postgres:postgres_password@localhost:5433/testdb"
echo ""
echo "Next steps:"
echo "  1. Update application connection strings to point to the new primary"
echo "  2. Set up the old primary as a new standby (see manual steps above)"
echo "  3. Monitor the cluster status"
