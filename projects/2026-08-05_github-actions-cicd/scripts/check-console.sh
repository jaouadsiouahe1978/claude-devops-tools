#!/bin/bash

###############################################################################
# Script pour vérifier les console.log en production
# Usage: ./scripts/check-console.sh [path]
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

TARGET_PATH="${1:-.}"

echo -e "${BLUE}🔍 Checking for console statements${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

FOUND=0

# Search for console statements
echo -e "${YELLOW}Searching in: $TARGET_PATH${NC}"

if grep -r "console\.\(log\|error\|warn\|info\)" "$TARGET_PATH" --include="*.js" 2>/dev/null | grep -v "node_modules" | grep -v "test"; then
  echo -e "${YELLOW}⚠️  Found console statements in production code${NC}"
  FOUND=1
else
  echo -e "${GREEN}✅ No console statements found${NC}"
fi

echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ $FOUND -eq 1 ]; then
  echo -e "${YELLOW}💡 Tip: Use proper logging library instead of console${NC}"
  exit 0  # Non-blocking
else
  echo -e "${GREEN}✅ Check complete${NC}"
  exit 0
fi
