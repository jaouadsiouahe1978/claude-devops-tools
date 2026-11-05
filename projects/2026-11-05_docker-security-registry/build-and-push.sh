#!/bin/bash
set -e

REGISTRY_URL="${1:-localhost:5000}"
IMAGE_TAG="${2:-v1.0.0}"

echo "🔨 Building Docker image..."
docker build -t secure-app:$IMAGE_TAG .

echo ""
echo "📏 Checking image size..."
SIZE=$(docker image inspect secure-app:$IMAGE_TAG --format='{{.Size}}' | numfmt --to=iec-i --suffix=B 2>/dev/null || echo "unknown")
echo "   Image size: $SIZE"

echo ""
echo "🔍 Quick security check..."
if command -v trivy &> /dev/null; then
    docker save secure-app:$IMAGE_TAG -o /tmp/image-$IMAGE_TAG.tar
    trivy image --severity HIGH,CRITICAL /tmp/image-$IMAGE_TAG.tar || true
    rm /tmp/image-$IMAGE_TAG.tar
else
    echo "   ⚠️  Trivy not installed, skipping scan"
fi

echo ""
echo "🚀 Tagging for registry..."
docker tag secure-app:$IMAGE_TAG $REGISTRY_URL/secure-app:$IMAGE_TAG
docker tag secure-app:$IMAGE_TAG $REGISTRY_URL/secure-app:latest

echo ""
echo "📤 Pushing to $REGISTRY_URL..."
docker push $REGISTRY_URL/secure-app:$IMAGE_TAG
docker push $REGISTRY_URL/secure-app:latest

echo ""
echo "✅ Done!"
echo ""
echo "Pull the image with:"
echo "   docker pull $REGISTRY_URL/secure-app:$IMAGE_TAG"
