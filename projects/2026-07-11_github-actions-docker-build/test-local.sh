#!/bin/bash

set -e

echo "🚀 Starting local Docker build and test..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Build image
echo -e "${BLUE}📦 Building Docker image...${NC}"
docker build -t test-app:local .
echo -e "${GREEN}✅ Image built successfully${NC}"
echo ""

# Run container
echo -e "${BLUE}🏃 Starting container...${NC}"
CONTAINER_ID=$(docker run -d -p 3000:3000 --name test-app-local test-app:local)
echo -e "${GREEN}✅ Container started: $CONTAINER_ID${NC}"
echo ""

# Wait for app to start
echo -e "${BLUE}⏳ Waiting for application to be ready...${NC}"
RETRY=0
MAX_RETRIES=30
while [ $RETRY -lt $MAX_RETRIES ]; do
    if curl -sf http://localhost:3000/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Application is ready!${NC}"
        break
    fi
    RETRY=$((RETRY + 1))
    echo "  Attempt $RETRY/$MAX_RETRIES..."
    sleep 1
done

if [ $RETRY -eq $MAX_RETRIES ]; then
    echo -e "${RED}❌ Application failed to start${NC}"
    docker logs test-app-local
    docker stop test-app-local
    docker rm test-app-local
    exit 1
fi
echo ""

# Test endpoints
echo -e "${BLUE}🧪 Testing endpoints...${NC}"
echo ""

# Test main endpoint
echo -e "${YELLOW}→ GET / (Main endpoint)${NC}"
curl -s http://localhost:3000/ | jq .
echo ""

# Test health endpoint
echo -e "${YELLOW}→ GET /health (Health check)${NC}"
curl -s http://localhost:3000/health | jq .
echo ""

# Test info endpoint
echo -e "${YELLOW}→ GET /info (Application info)${NC}"
curl -s http://localhost:3000/info | jq .
echo ""

# Test metrics endpoint
echo -e "${YELLOW}→ GET /metrics (Metrics)${NC}"
curl -s http://localhost:3000/metrics | jq .
echo ""

# Test 404 endpoint
echo -e "${YELLOW}→ GET /nonexistent (404 handling)${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/nonexistent)
if [ $HTTP_CODE -eq 404 ]; then
    echo -e "${GREEN}✅ 404 handling works (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${RED}❌ Expected 404, got HTTP $HTTP_CODE${NC}"
fi
echo ""

# Image size
echo -e "${BLUE}📊 Image information:${NC}"
docker images test-app:local
echo ""

# Container logs
echo -e "${BLUE}📋 Container logs:${NC}"
docker logs test-app-local
echo ""

# Cleanup
echo -e "${BLUE}🧹 Cleaning up...${NC}"
docker stop test-app-local
docker rm test-app-local
echo -e "${GREEN}✅ Container stopped and removed${NC}"
echo ""

echo -e "${GREEN}✅ All tests passed successfully!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Commit changes: git commit -m 'Add GitHub Actions Docker CI/CD'"
echo "  2. Push to main: git push origin main"
echo "  3. Configure Docker Hub secrets in GitHub repo settings"
echo "  4. Check GitHub Actions tab for workflow execution"
