#!/bin/bash
# Quick start script for Traefik Reverse Proxy project

set -e

echo "======================================"
echo "Traefik Reverse Proxy - Quick Start"
echo "======================================"
echo ""

# Check if Docker is running
echo "✓ Checking Docker installation..."
if ! command -v docker &> /dev/null; then
    echo "✗ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! docker info > /dev/null 2>&1; then
    echo "✗ Docker daemon is not running. Please start Docker."
    exit 1
fi

echo "✓ Docker is running"
echo ""

# Setup acme.json permissions
echo "✓ Setting up certificate storage..."
if [ ! -f acme.json ]; then
    touch acme.json
fi
chmod 600 acme.json
echo "✓ acme.json permissions set correctly"
echo ""

# Build custom images
echo "✓ Building API Docker image..."
docker-compose build --no-cache
echo "✓ API image built successfully"
echo ""

# Start services
echo "✓ Starting Traefik and services..."
docker-compose up -d
echo "✓ All services are starting..."
echo ""

# Wait for services to be ready
echo "⏳ Waiting for services to start (10 seconds)..."
sleep 10

# Check status
echo "✓ Checking service status..."
docker-compose ps
echo ""

# Display connection information
echo "======================================"
echo "Traefik is now running!"
echo "======================================"
echo ""
echo "Access points:"
echo "  🎛️  Dashboard:     http://localhost:8080"
echo "  🌐 Web Service 1:  http://web1.localhost"
echo "  🌐 Web Service 2:  http://web2.localhost"
echo "  📡 API Service:    http://api.localhost"
echo ""
echo "Available API endpoints:"
echo "  GET  /                    - Home"
echo "  GET  /health              - Health check"
echo "  GET  /api/services        - List all services"
echo "  GET  /api/services/<name> - Get specific service"
echo "  GET  /api/request-info    - Get request information"
echo "  POST /api/echo            - Echo endpoint"
echo ""
echo "Test commands:"
echo "  curl http://web1.localhost"
echo "  curl http://api.localhost/api/services"
echo "  curl http://api.localhost/health"
echo ""
echo "View logs:"
echo "  docker-compose logs -f traefik"
echo "  docker-compose logs -f api"
echo ""
echo "Stop services:"
echo "  docker-compose down"
echo ""
