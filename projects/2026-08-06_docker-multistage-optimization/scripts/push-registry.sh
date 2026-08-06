#!/bin/bash

set -e

echo "📤 Pushing images to local Docker Registry"
echo "════════════════════════════════════════════"
echo ""

# Check if registry is running
echo "Checking registry availability..."
if ! curl -s http://localhost:5000/v2/_catalog &>/dev/null; then
    echo "❌ Registry not available at localhost:5000"
    echo "   Start it with: docker-compose up -d registry"
    exit 1
fi

echo "✅ Registry is running"
echo ""

# Tag and push images
IMAGES=("app:bad" "app:optimized" "nginx:optimized")
VERSION="v1.0.0"

for img in "${IMAGES[@]}"; do
    NAME=$(echo $img | cut -d: -f1)
    TAG=$(echo $img | cut -d: -f2)
    REMOTE_TAG="localhost:5000/${NAME}:${TAG}"

    echo "📦 Tagging ${img} → ${REMOTE_TAG}..."
    docker tag "$img" "$REMOTE_TAG"

    echo "📤 Pushing ${REMOTE_TAG}..."
    docker push "$REMOTE_TAG" 2>&1 | tail -3
    echo ""
done

echo "════════════════════════════════════════════"
echo "✅ Push complete!"
echo ""
echo "📋 Images in registry:"
curl -s http://localhost:5000/v2/_catalog | jq '.repositories'
echo ""
echo "💡 Useful commands:"
echo "  # List tags of an image"
echo "  curl http://localhost:5000/v2/app/tags/list | jq '.tags'"
echo ""
echo "  # Pull an image from local registry"
echo "  docker pull localhost:5000/app:optimized"
echo ""
echo "  # Delete an image from registry"
echo "  curl -X DELETE http://localhost:5000/v2/app/manifests/\$(curl -s http://localhost:5000/v2/app/manifests/v1.0.0 -I | grep -i docker-content | tail -1 | awk '{print \$NF}')"
