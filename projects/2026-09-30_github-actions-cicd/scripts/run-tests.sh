#!/bin/bash

set -e

echo "🧪 Running Tests..."

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if poetry is installed
if ! command -v poetry &> /dev/null; then
    echo -e "${RED}Poetry is not installed${NC}"
    exit 1
fi

# Install dependencies
echo -e "${YELLOW}Installing dependencies...${NC}"
poetry install

# Run tests with coverage
echo -e "${YELLOW}Running pytest with coverage...${NC}"
poetry run pytest tests/ -v --cov=app --cov-report=term-plus-coverage --cov-report=html

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Tests passed${NC}"
    echo -e "${YELLOW}Coverage report generated in htmlcov/index.html${NC}"
else
    echo -e "${RED}✗ Tests failed${NC}"
    exit 1
fi

# Run linting
echo -e "${YELLOW}Running pylint...${NC}"
poetry run pylint app/ --disable=all --enable=E,F || true

echo -e "${YELLOW}Running flake8...${NC}"
poetry run flake8 app/ --max-line-length=100 || true

# Run formatting check
echo -e "${YELLOW}Checking code format with black...${NC}"
poetry run black app/ tests/ --check || true

echo -e "${GREEN}✓ All checks completed${NC}"
