#!/bin/bash

# Create a new project in Harbor
# Usage: ./create-project.sh <project_name> [--public]

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <project_name> [--public|--private]"
    echo ""
    echo "Examples:"
    echo "  $0 myproject"
    echo "  $0 myproject --public"
    exit 1
fi

PROJECT_NAME="$1"
PUBLIC=false

if [ "$2" = "--public" ]; then
    PUBLIC=true
fi

HARBOR_URL="http://localhost:8080"
HARBOR_USER="admin"
HARBOR_PASSWORD="Harbor12345"

echo "🏗️  Creating Harbor project: $PROJECT_NAME"

# Create project via API
RESPONSE=$(curl -s -X POST \
  "$HARBOR_URL/api/v2.0/projects" \
  -H "Authorization: Basic $(echo -n $HARBOR_USER:$HARBOR_PASSWORD | base64)" \
  -H "Content-Type: application/json" \
  -d "{
    \"project_name\": \"$PROJECT_NAME\",
    \"public\": $PUBLIC,
    \"metadata\": {
      \"enable_content_trust\": \"false\",
      \"enable_content_trust_cosign\": \"false\",
      \"enable_content_trust_cosign\": \"false\",
      \"auto_scan\": \"true\",
      \"severity\": \"high\"
    }
  }" \
  -w "%{http_code}")

# Check response
HTTP_CODE="${RESPONSE: -3}"
if [ "$HTTP_CODE" = "201" ]; then
    echo "✅ Project created successfully!"
    echo ""
    echo "🔧 Project configuration:"
    echo "  • Name: $PROJECT_NAME"
    echo "  • Visibility: $([ "$PUBLIC" = true ] && echo "Public" || echo "Private")"
    echo "  • Auto-scan: Enabled"
    echo "  • Severity threshold: High"
    echo ""
    echo "📍 Push images to: localhost:5000/$PROJECT_NAME/<image>:<tag>"
    echo ""
    echo "Example:"
    echo "  docker tag myapp:latest localhost:5000/$PROJECT_NAME/myapp:latest"
    echo "  docker push localhost:5000/$PROJECT_NAME/myapp:latest"
elif [ "$HTTP_CODE" = "409" ]; then
    echo "⚠️  Project already exists"
    exit 1
else
    echo "❌ Failed to create project (HTTP $HTTP_CODE)"
    echo "Response: ${RESPONSE%???}"
    exit 1
fi
