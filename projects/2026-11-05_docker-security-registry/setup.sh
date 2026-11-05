#!/bin/bash
set -e

ACTION="${1:-start}"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📦 Docker Security & Registry Setup"
echo "===================================="

case "$ACTION" in
  start)
    echo "🚀 Starting Docker Compose stack..."
    cd "$PROJECT_DIR"
    docker-compose up -d
    echo ""
    sleep 2
    echo "✅ Services started!"
    echo ""
    echo "📋 Services:"
    docker-compose ps
    echo ""
    echo "🔗 Registry: http://localhost:5000"
    echo "🌐 App:      http://localhost:3000"
    echo "💚 Health:   curl http://localhost:3000/health"
    ;;

  stop)
    echo "🛑 Stopping Docker Compose stack..."
    cd "$PROJECT_DIR"
    docker-compose down
    echo "✅ Services stopped!"
    ;;

  clean)
    echo "🧹 Cleaning up volumes and images..."
    cd "$PROJECT_DIR"
    docker-compose down -v
    docker rmi secure-app:latest 2>/dev/null || true
    echo "✅ Cleanup complete!"
    ;;

  logs)
    echo "📊 Showing logs..."
    cd "$PROJECT_DIR"
    docker-compose logs -f
    ;;

  status)
    echo "📊 Stack status:"
    cd "$PROJECT_DIR"
    docker-compose ps
    echo ""
    echo "🔍 Registry status:"
    curl -s http://localhost:5000/v2/ > /dev/null && echo "✅ Registry OK" || echo "❌ Registry not responding"
    echo ""
    echo "🔍 App status:"
    curl -s http://localhost:3000/health > /dev/null && echo "✅ App OK" || echo "❌ App not responding"
    ;;

  *)
    echo "Usage: ./setup.sh [start|stop|clean|logs|status]"
    echo ""
    echo "Commands:"
    echo "  start  - Start the Docker Compose stack"
    echo "  stop   - Stop the stack"
    echo "  clean  - Stop and clean up volumes"
    echo "  logs   - Show live logs"
    echo "  status - Check services status"
    exit 1
    ;;
esac
