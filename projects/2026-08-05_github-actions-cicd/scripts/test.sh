#!/bin/bash

###############################################################################
# Script pour exécuter les tests
# Usage: ./scripts/test.sh [--watch] [--coverage]
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default options
TEST_FLAGS=""
WATCH_MODE=false
COVERAGE_MODE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --watch)
      WATCH_MODE=true
      TEST_FLAGS="$TEST_FLAGS --watch"
      shift
      ;;
    --coverage)
      COVERAGE_MODE=true
      TEST_FLAGS="$TEST_FLAGS --coverage"
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo -e "${BLUE}🧪 Running Test Suite${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Verify dependencies are installed
if [ ! -d "node_modules" ]; then
  echo -e "${YELLOW}📦 Installing dependencies...${NC}"
  npm ci
fi

# Run tests
if npm run test -- $TEST_FLAGS; then
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}✅ All tests passed!${NC}"

  if [ "$COVERAGE_MODE" = true ]; then
    echo -e "${YELLOW}📊 Coverage Report:${NC}"
    if [ -f "coverage/coverage-summary.json" ]; then
      node -e "
        const data = require('./coverage/coverage-summary.json');
        const total = data.total;
        console.log('  Statements: ' + total.statements.pct + '%');
        console.log('  Branches:   ' + total.branches.pct + '%');
        console.log('  Functions:  ' + total.functions.pct + '%');
        console.log('  Lines:      ' + total.lines.pct + '%');
      "
    fi
  fi

  exit 0
else
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${RED}❌ Tests failed!${NC}"
  exit 1
fi
