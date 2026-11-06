#!/bin/bash

set -e

echo "╔════════════════════════════════════════════════╗"
echo "║  GitHub Actions CD with Approval Gates Setup  ║"
echo "╚════════════════════════════════════════════════╝"
echo ""

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo "📁 Project directory: $PROJECT_DIR"
echo ""

# Check dependencies
echo "🔍 Checking dependencies..."
command -v docker >/dev/null 2>&1 || { echo "❌ Docker not installed"; exit 1; }
command -v docker-compose >/dev/null 2>&1 || { echo "❌ Docker Compose not installed"; exit 1; }
command -v node >/dev/null 2>&1 || { echo "❌ Node.js not installed"; exit 1; }
echo "✅ All dependencies found"
echo ""

# Install Node dependencies
echo "📦 Installing Node.js dependencies..."
if [ ! -d "node_modules" ]; then
  npm install
else
  echo "   (npm packages already installed)"
fi
echo "✅ Dependencies installed"
echo ""

# Build Docker image
echo "🐳 Building Docker image..."
docker build -t myapp:latest .
echo "✅ Docker image built"
echo ""

# Start services
echo "🚀 Starting services with docker-compose..."
docker-compose up -d
echo "✅ Services started"
echo ""

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
for i in {1..30}; do
  if curl -f http://localhost:3000/health >/dev/null 2>&1; then
    echo "✅ Application is healthy"
    break
  fi
  if [ $i -eq 30 ]; then
    echo "❌ Application failed to start"
    docker-compose logs app
    exit 1
  fi
  echo "   Attempt $i/30..."
  sleep 2
done
echo ""

# Display service endpoints
echo "╔════════════════════════════════════════════════╗"
echo "║          🎉 Setup Complete! 🎉               ║"
echo "╚════════════════════════════════════════════════╝"
echo ""
echo "📍 Service Endpoints:"
echo ""
echo "   🌐 Application    : http://localhost:3000"
echo "   🌐 Via Nginx      : http://localhost:8080"
echo "   ❤️ Health Check   : http://localhost:3000/health"
echo "   📊 Metrics        : http://localhost:3000/api/metrics"
echo "   ℹ️ Info          : http://localhost:3000/api/info"
echo "   ⚙️ Config         : http://localhost:3000/api/config"
echo ""
echo "🛑 Stop services:"
echo "   docker-compose down"
echo ""
echo "📖 View logs:"
echo "   docker-compose logs -f app"
echo ""
echo "🧪 Test endpoints:"
echo "   curl http://localhost:3000/health"
echo "   curl http://localhost:3000/api/info"
echo ""
echo "📚 Next steps:"
echo "   1. Read DEPLOYMENT.md for GitHub setup"
echo "   2. Read WORKFLOWS.md to understand CI/CD flow"
echo "   3. Read SECRETS.md to configure secrets"
echo "   4. Test the application locally"
echo "   5. Push to GitHub to trigger workflows"
echo ""

# Show running containers
echo "📦 Running containers:"
docker-compose ps
echo ""

echo "✅ Ready to deploy! Push your code to GitHub to trigger workflows."
