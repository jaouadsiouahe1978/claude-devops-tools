#!/bin/bash

###############################################################################
# Script de linting et validation du code
# Usage: ./scripts/lint.sh [--fix]
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default options
FIX_FLAG=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --fix)
      FIX_FLAG="--fix"
      echo -e "${YELLOW}ℹ️  Running linter in fix mode${NC}"
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo -e "${YELLOW}🔍 Running ESLint checks...${NC}"

# Run ESLint
if npm run lint:check $FIX_FLAG; then
  echo -e "${GREEN}✅ Linting passed!${NC}"
else
  echo -e "${RED}❌ Linting failed!${NC}"
  exit 1
fi

# Check for multiple spaces
echo -e "${YELLOW}🔍 Checking for multiple spaces...${NC}"
if grep -r "  " src/ tests/ --include="*.js" | grep -v node_modules; then
  echo -e "${YELLOW}⚠️  Multiple spaces found (not critical)${NC}"
else
  echo -e "${GREEN}✅ No multiple spaces found${NC}"
fi

# Check for TODO comments
echo -e "${YELLOW}🔍 Checking for TODO comments...${NC}"
TODO_COUNT=$(grep -r "TODO" src/ tests/ --include="*.js" 2>/dev/null | wc -l)
if [ "$TODO_COUNT" -gt 0 ]; then
  echo -e "${YELLOW}⚠️  Found $TODO_COUNT TODO comments:${NC}"
  grep -r "TODO" src/ tests/ --include="*.js" || true
else
  echo -e "${GREEN}✅ No TODO comments found${NC}"
fi

echo -e "${GREEN}✨ Linting validation complete!${NC}"
