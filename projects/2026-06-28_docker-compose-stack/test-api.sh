#!/bin/bash

# Test script for Docker Compose stack
# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BASE_URL="http://localhost"
API_URL="${BASE_URL}/api"

echo -e "${YELLOW}🧪 Docker Compose Stack API Tests${NC}\n"

# Test 1: Health check
echo -e "${YELLOW}1. Testing Health Check...${NC}"
response=$(curl -s -w "\n%{http_code}" ${API_URL}/health)
http_code=$(echo "$response" | tail -n 1)
body=$(echo "$response" | head -n -1)

if [ "$http_code" = "200" ]; then
    echo -e "${GREEN}✓ Health check passed${NC}"
    echo "Response: $body" | jq '.'
else
    echo -e "${RED}✗ Health check failed (HTTP $http_code)${NC}"
fi

echo ""

# Test 2: Get all tasks
echo -e "${YELLOW}2. Getting All Tasks...${NC}"
response=$(curl -s -w "\n%{http_code}" ${API_URL}/tasks)
http_code=$(echo "$response" | tail -n 1)
body=$(echo "$response" | head -n -1)

if [ "$http_code" = "200" ]; then
    echo -e "${GREEN}✓ Get tasks succeeded${NC}"
    echo "Response:"
    echo "$body" | jq '.'
else
    echo -e "${RED}✗ Get tasks failed (HTTP $http_code)${NC}"
fi

echo ""

# Test 3: Create a new task
echo -e "${YELLOW}3. Creating a New Task...${NC}"
response=$(curl -s -w "\n%{http_code}" -X POST \
    -H "Content-Type: application/json" \
    -d '{"title":"Test Task via API","description":"Testing Docker Compose stack","status":"pending"}' \
    ${API_URL}/tasks)
http_code=$(echo "$response" | tail -n 1)
body=$(echo "$response" | head -n -1)

if [ "$http_code" = "201" ]; then
    echo -e "${GREEN}✓ Task creation succeeded${NC}"
    echo "Response:"
    echo "$body" | jq '.'
    # Extract task ID for later use
    TASK_ID=$(echo "$body" | jq -r '.id')
else
    echo -e "${RED}✗ Task creation failed (HTTP $http_code)${NC}"
fi

echo ""

# Test 4: Get specific task (if we created one)
if [ ! -z "$TASK_ID" ] && [ "$TASK_ID" != "null" ]; then
    echo -e "${YELLOW}4. Getting Specific Task (ID: $TASK_ID)...${NC}"
    response=$(curl -s -w "\n%{http_code}" ${API_URL}/tasks/${TASK_ID})
    http_code=$(echo "$response" | tail -n 1)
    body=$(echo "$response" | head -n -1)

    if [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✓ Get task succeeded${NC}"
        echo "Response:"
        echo "$body" | jq '.'
    else
        echo -e "${RED}✗ Get task failed (HTTP $http_code)${NC}"
    fi

    echo ""

    # Test 5: Update task
    echo -e "${YELLOW}5. Updating Task (ID: $TASK_ID)...${NC}"
    response=$(curl -s -w "\n%{http_code}" -X PUT \
        -H "Content-Type: application/json" \
        -d '{"status":"in_progress","description":"Updated via API test"}' \
        ${API_URL}/tasks/${TASK_ID})
    http_code=$(echo "$response" | tail -n 1)
    body=$(echo "$response" | head -n -1)

    if [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✓ Task update succeeded${NC}"
        echo "Response:"
        echo "$body" | jq '.'
    else
        echo -e "${RED}✗ Task update failed (HTTP $http_code)${NC}"
    fi

    echo ""
fi

# Test 6: Get statistics
echo -e "${YELLOW}6. Getting Task Statistics...${NC}"
response=$(curl -s -w "\n%{http_code}" ${API_URL}/stats)
http_code=$(echo "$response" | tail -n 1)
body=$(echo "$response" | head -n -1)

if [ "$http_code" = "200" ]; then
    echo -e "${GREEN}✓ Statistics retrieved${NC}"
    echo "Response:"
    echo "$body" | jq '.'
else
    echo -e "${RED}✗ Statistics retrieval failed (HTTP $http_code)${NC}"
fi

echo ""
echo -e "${YELLOW}🎉 Tests completed!${NC}"
