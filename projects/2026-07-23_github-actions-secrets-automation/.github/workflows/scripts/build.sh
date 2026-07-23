#!/bin/bash
set -e
echo "🔨 Starting build..."
mkdir -p build
cd build
cp -r ../src .
cp ../Dockerfile .
echo "🐳 Building Docker image..."
docker build -t app:latest .
echo "✅ Build complete"
