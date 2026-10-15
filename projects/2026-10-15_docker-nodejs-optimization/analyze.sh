#!/bin/bash

# Script to analyze Docker image sizes and layers
# Usage: ./analyze.sh [image-name]

IMAGE_NAME=${1:-devops-app:v1}

echo "=========================================="
echo "🔍 Docker Image Analysis Tool"
echo "=========================================="
echo ""

# Check if image exists
if ! docker image inspect "$IMAGE_NAME" > /dev/null 2>&1; then
    echo "❌ Image '$IMAGE_NAME' not found!"
    echo "Build it first: docker build -t $IMAGE_NAME ."
    exit 1
fi

# Show image size
echo "📊 Image Size:"
docker images | grep -E "REPOSITORY|$IMAGE_NAME"
echo ""

# Show detailed size information
echo "📈 Detailed Size Info:"
docker image inspect "$IMAGE_NAME" | grep -E '"Size"|"VirtualSize"'
echo ""

# Show image layers
echo "🧅 Image Layers (Dockerfile -> Container):"
docker history "$IMAGE_NAME"
echo ""

# Show OS/Distro info
echo "🐧 OS Information:"
docker run --rm "$IMAGE_NAME" sh -c "cat /etc/os-release | grep -E 'NAME|VERSION'"
echo ""

# Show installed packages
echo "📦 Installed npm packages (production only):"
docker run --rm "$IMAGE_NAME" npm list --depth=0
echo ""

# File system usage
echo "💾 Filesystem Usage:"
docker run --rm "$IMAGE_NAME" sh -c "du -sh / 2>/dev/null | head -5"
echo ""

echo "=========================================="
echo "✅ Analysis complete!"
echo "=========================================="
