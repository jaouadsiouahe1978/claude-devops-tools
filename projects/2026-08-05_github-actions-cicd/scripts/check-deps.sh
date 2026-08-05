#!/bin/bash

###############################################################################
# Script pour vérifier les dépendances
# Usage: ./scripts/check-deps.sh
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Checking Dependencies${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

FAILED=0

# Check Node.js
echo -e "${YELLOW}Checking Node.js...${NC}"
if command -v node &> /dev/null; then
  NODE_VERSION=$(node --version)
  echo -e "${GREEN}✅ Node.js installed: $NODE_VERSION${NC}"
else
  echo -e "${RED}❌ Node.js not found${NC}"
  FAILED=1
fi

# Check npm
echo -e "${YELLOW}Checking npm...${NC}"
if command -v npm &> /dev/null; then
  NPM_VERSION=$(npm --version)
  echo -e "${GREEN}✅ npm installed: $NPM_VERSION${NC}"
else
  echo -e "${RED}❌ npm not found${NC}"
  FAILED=1
fi

# Check bash
echo -e "${YELLOW}Checking Bash...${NC}"
if command -v bash &> /dev/null; then
  BASH_VERSION=$(bash --version | head -1)
  echo -e "${GREEN}✅ Bash installed: $BASH_VERSION${NC}"
else
  echo -e "${RED}❌ Bash not found${NC}"
  FAILED=1
fi

# Check git
echo -e "${YELLOW}Checking Git...${NC}"
if command -v git &> /dev/null; then
  GIT_VERSION=$(git --version)
  echo -e "${GREEN}✅ Git installed: $GIT_VERSION${NC}"
else
  echo -e "${RED}❌ Git not found${NC}"
  FAILED=1
fi

# Check npm packages
echo -e "${YELLOW}Checking npm packages...${NC}"
if [ -d "node_modules" ]; then
  PACKAGE_COUNT=$(ls -la node_modules/ | wc -l)
  echo -e "${GREEN}✅ node_modules directory exists ($PACKAGE_COUNT entries)${NC}"
else
  echo -e "${YELLOW}⚠️  node_modules not installed${NC}"
  echo -e "${YELLOW}   Run: npm install${NC}"
fi

# Check required npm packages
echo -e "${YELLOW}Checking required packages...${NC}"
REQUIRED_PACKAGES=("eslint" "jest" "axios")

for package in "${REQUIRED_PACKAGES[@]}"; do
  if npm list "$package" &>/dev/null; then
    VERSION=$(npm list "$package" | grep "$package@" | head -1 | awk '{print $2}')
    echo -e "${GREEN}✅ $package: $VERSION${NC}"
  else
    echo -e "${RED}❌ $package: not installed${NC}"
    FAILED=1
  fi
done

# Check script files
echo -e "${YELLOW}Checking build scripts...${NC}"
SCRIPTS=("lint.sh" "test.sh" "build.sh" "check-deps.sh")
for script in "${SCRIPTS[@]}"; do
  if [ -f "scripts/$script" ]; then
    if [ -x "scripts/$script" ]; then
      echo -e "${GREEN}✅ scripts/$script (executable)${NC}"
    else
      echo -e "${YELLOW}⚠️  scripts/$script (not executable)${NC}"
      echo -e "${YELLOW}   Run: chmod +x scripts/$script${NC}"
    fi
  else
    echo -e "${RED}❌ scripts/$script (missing)${NC}"
    FAILED=1
  fi
done

echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}✅ All dependencies are OK!${NC}"
  exit 0
else
  echo -e "${RED}❌ Some dependencies are missing!${NC}"
  exit 1
fi
