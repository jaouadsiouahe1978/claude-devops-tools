#!/bin/bash

###############################################################################
# Script de build et compilation
# Usage: ./scripts/build.sh
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔨 Building Application${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
  echo -e "${YELLOW}📦 Installing dependencies...${NC}"
  npm ci
fi

# Create dist directory
DIST_DIR="dist"
echo -e "${YELLOW}📁 Creating build directory...${NC}"
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

# Copy source files
echo -e "${YELLOW}📋 Copying source files...${NC}"
cp -r src/* "$DIST_DIR/"
cp package.json "$DIST_DIR/"

# Run linting
echo -e "${YELLOW}🔍 Running linting checks...${NC}"
if npm run lint:check; then
  echo -e "${GREEN}  ✅ Linting passed${NC}"
else
  echo -e "${RED}  ❌ Linting failed${NC}"
  exit 1
fi

# Run tests
echo -e "${YELLOW}🧪 Running tests...${NC}"
if npm run test -- --passWithNoTests; then
  echo -e "${GREEN}  ✅ Tests passed${NC}"
else
  echo -e "${RED}  ❌ Tests failed${NC}"
  exit 1
fi

# Check security vulnerabilities
echo -e "${YELLOW}🔒 Checking for vulnerabilities...${NC}"
if npm audit --audit-level=high 2>/dev/null | grep -q "found 0 vulnerabilities"; then
  echo -e "${GREEN}  ✅ No critical vulnerabilities found${NC}"
else
  echo -e "${YELLOW}  ⚠️  Some vulnerabilities found (non-blocking)${NC}"
fi

# Generate build info
echo -e "${YELLOW}📝 Generating build info...${NC}"
cat > "$DIST_DIR/BUILD_INFO.json" << EOF
{
  "buildDate": "$(date -u +'%Y-%m-%dT%H:%M:%SZ')",
  "gitCommit": "${GIT_COMMIT:-$(git rev-parse HEAD 2>/dev/null || echo 'unknown')}",
  "gitBranch": "${GIT_BRANCH:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'unknown')}",
  "nodeVersion": "$(node --version)",
  "npmVersion": "$(npm --version)"
}
EOF

# Calculate total size
TOTAL_SIZE=$(du -sh "$DIST_DIR" | awk '{print $1}')
FILE_COUNT=$(find "$DIST_DIR" -type f | wc -l)

echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Build completed successfully!${NC}"
echo -e "${BLUE}📊 Build Summary:${NC}"
echo -e "  ${BLUE}Dist directory:${NC} $DIST_DIR"
echo -e "  ${BLUE}Total size:${NC} $TOTAL_SIZE"
echo -e "  ${BLUE}Files:${NC} $FILE_COUNT"
echo -e ""
echo -e "${YELLOW}🎉 Ready for deployment!${NC}"
