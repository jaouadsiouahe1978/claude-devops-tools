#!/bin/bash

# Setup script for Docker Registry + Trivy Security Stack
# Creates directories, starts containers, and initializes services

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🚀 Setting up Docker Registry + Trivy Security Stack..."
echo "📍 Project root: $PROJECT_ROOT"

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed"
    exit 1
fi

echo "✅ Docker found: $(docker --version)"

# Check Docker Compose
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not installed"
    exit 1
fi

echo "✅ Docker Compose available"

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p "$PROJECT_ROOT/harbor"
mkdir -p "$PROJECT_ROOT/scripts"
mkdir -p "$PROJECT_ROOT/images/nodejs"
mkdir -p "$PROJECT_ROOT/images/python"
mkdir -p "$PROJECT_ROOT/images/golang"
mkdir -p "$PROJECT_ROOT/ci-cd/.github/workflows"
mkdir -p "$PROJECT_ROOT/trivy/policies"
mkdir -p "$PROJECT_ROOT/docs"
mkdir -p "$PROJECT_ROOT/tests"

# Start containers
echo "🐳 Starting Docker containers..."
cd "$PROJECT_ROOT"
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for Harbor to be ready (30s)..."
sleep 30

# Check Harbor API
echo "🔍 Checking Harbor API..."
for i in {1..10}; do
    if curl -s http://localhost:8080/api/v2.0/systeminfo > /dev/null 2>&1; then
        echo "✅ Harbor is ready!"
        break
    fi
    echo "  Attempt $i/10..."
    sleep 5
done

# Check Trivy
echo "🔍 Checking Trivy..."
for i in {1..5}; do
    if curl -s http://localhost:8081/api/v1/vulnerability > /dev/null 2>&1; then
        echo "✅ Trivy is ready!"
        break
    fi
    echo "  Attempt $i/5..."
    sleep 3
done

# Test Docker Registry
echo "🔍 Checking Docker Registry..."
if curl -s http://localhost:5000/v2/_catalog > /dev/null 2>&1; then
    echo "✅ Docker Registry is ready!"
fi

echo ""
echo "=================================="
echo "✅ Setup Complete!"
echo "=================================="
echo ""
echo "🌐 Access points:"
echo "  • Harbor UI:     http://localhost:8080"
echo "  • Harbor API:    http://localhost:8080/api/v2.0"
echo "  • Registry:      localhost:5000"
echo "  • Trivy API:     http://localhost:8081"
echo "  • PostgreSQL:    localhost:5432"
echo "  • Redis:         localhost:6379"
echo ""
echo "👤 Credentials:"
echo "  • Harbor Admin:  admin / Harbor12345"
echo ""
echo "📖 Next steps:"
echo "  1. Create a project: ./scripts/create-project.sh myproject"
echo "  2. Build an image:  cd images/nodejs && docker build -t localhost:5000/myproject/app:v1 ."
echo "  3. Scan with Trivy: ../scripts/scan-image.sh localhost:5000/myproject/app:v1"
echo "  4. Push to Harbor:  docker push localhost:5000/myproject/app:v1"
echo ""
echo "✨ Happy scanning!"
