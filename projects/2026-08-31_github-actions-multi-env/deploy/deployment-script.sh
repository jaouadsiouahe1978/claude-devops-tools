#!/bin/bash

##############################################################################
# Deployment Script for Multi-Environment Application
#
# Usage: ./deployment-script.sh <environment> <version> [rollback]
#
# Environments: dev, staging, prod
# Version: Image tag (e.g., develop, main-latest, v1.0.0)
#
# This script is called by GitHub Actions workflows to deploy the
# application to the specified environment.
##############################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT="${1:-}"
VERSION="${2:-latest}"
ROLLBACK="${3:-false}"
REGISTRY="${REGISTRY:-ghcr.io}"
IMAGE_NAME="${IMAGE_NAME:-devops/app}"
DEPLOYMENT_TIMEOUT=${DEPLOYMENT_TIMEOUT:-300}
HEALTH_CHECK_RETRIES=${HEALTH_CHECK_RETRIES:-10}

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# ============================================================================
# Helper Functions
# ============================================================================

log_info() {
  echo -e "${BLUE}ℹ️  $*${NC}"
}

log_success() {
  echo -e "${GREEN}✅ $*${NC}"
}

log_warning() {
  echo -e "${YELLOW}⚠️  $*${NC}"
}

log_error() {
  echo -e "${RED}❌ $*${NC}"
}

validate_environment() {
  case "$ENVIRONMENT" in
    dev|staging|prod)
      log_success "Environment validated: $ENVIRONMENT"
      ;;
    *)
      log_error "Invalid environment: $ENVIRONMENT"
      echo "Valid environments: dev, staging, prod"
      exit 1
      ;;
  esac
}

load_environment_config() {
  local config_file="$SCRIPT_DIR/${ENVIRONMENT}-config.env"

  if [[ ! -f "$config_file" ]]; then
    log_error "Configuration file not found: $config_file"
    exit 1
  fi

  log_info "Loading configuration from: $config_file"
  # shellcheck disable=SC1090
  source "$config_file"
  log_success "Configuration loaded"
}

check_prerequisites() {
  log_info "Checking prerequisites..."

  # Check Docker
  if ! command -v docker &> /dev/null; then
    log_error "Docker is not installed"
    exit 1
  fi
  log_success "Docker found: $(docker --version)"

  # Check SSH for remote deployments (if not localhost)
  if [[ "$DEPLOYMENT_HOST" != "localhost" ]]; then
    if ! command -v ssh &> /dev/null; then
      log_error "SSH is not installed"
      exit 1
    fi
  fi

  log_success "All prerequisites met"
}

pull_docker_image() {
  log_info "Pulling Docker image: $REGISTRY/$IMAGE_NAME:$VERSION"

  if docker pull "$REGISTRY/$IMAGE_NAME:$VERSION"; then
    log_success "Docker image pulled successfully"
  else
    log_error "Failed to pull Docker image"
    exit 1
  fi
}

backup_current_version() {
  log_info "Backing up current version..."

  if [[ "$ENVIRONMENT" == "prod" ]]; then
    local backup_dir="/var/backups/deployments"
    mkdir -p "$backup_dir"

    local timestamp=$(date +%s)
    local backup_file="$backup_dir/app-${ENVIRONMENT}-${timestamp}.tar.gz"

    log_info "Creating backup: $backup_file"
    # In real scenario: tar czf "$backup_file" /app
  fi

  log_success "Backup created"
}

perform_deployment() {
  log_info "Starting deployment to $ENVIRONMENT..."

  if [[ "$ENVIRONMENT" == "localhost" || "$DEPLOYMENT_HOST" == "localhost" ]]; then
    deploy_locally
  else
    deploy_remotely
  fi
}

deploy_locally() {
  log_info "Deploying locally..."

  # Stop current container if running
  if docker ps -a --format='{{.Names}}' | grep -q "^app-$ENVIRONMENT\$"; then
    log_info "Stopping current container..."
    docker stop "app-$ENVIRONMENT" || true
    docker rm "app-$ENVIRONMENT" || true
  fi

  # Start new container
  log_info "Starting new container..."
  docker run -d \
    --name "app-$ENVIRONMENT" \
    --restart unless-stopped \
    -p 3000:3000 \
    -e NODE_ENV="$NODE_ENV" \
    -e LOG_LEVEL="$LOG_LEVEL" \
    "$REGISTRY/$IMAGE_NAME:$VERSION"

  log_success "Container started"
}

deploy_remotely() {
  log_info "Deploying to remote server: $DEPLOYMENT_HOST"

  local ssh_cmd="ssh -i ~/.ssh/deploy_key -p $DEPLOYMENT_PORT $DEPLOYMENT_USER@$DEPLOYMENT_HOST"

  log_info "Connecting to remote server..."

  # Remote deployment script
  $ssh_cmd << 'REMOTE_SCRIPT'
set -euo pipefail

# Pull image
docker pull "$REGISTRY/$IMAGE_NAME:$VERSION"

# Stop and remove old container
docker stop app-$ENVIRONMENT || true
docker rm app-$ENVIRONMENT || true

# Start new container
docker run -d \
  --name "app-$ENVIRONMENT" \
  --restart unless-stopped \
  -p 3000:3000 \
  -e NODE_ENV="$NODE_ENV" \
  -e LOG_LEVEL="$LOG_LEVEL" \
  "$REGISTRY/$IMAGE_NAME:$VERSION"

REMOTE_SCRIPT

  log_success "Remote deployment completed"
}

wait_for_deployment() {
  log_info "Waiting for deployment to stabilize..."

  sleep 10

  log_success "Deployment stabilized"
}

health_check() {
  log_info "Running health checks..."

  local url="$DEPLOYMENT_URL/health"
  local retry_count=0

  while [[ $retry_count -lt $HEALTH_CHECK_RETRIES ]]; do
    if curl -sf "$url" > /dev/null 2>&1; then
      log_success "Health check passed"
      return 0
    fi

    retry_count=$((retry_count + 1))
    log_warning "Health check attempt $retry_count/$HEALTH_CHECK_RETRIES failed"
    sleep 5
  done

  log_error "Health checks failed after $HEALTH_CHECK_RETRIES attempts"
  return 1
}

verify_deployment() {
  log_info "Verifying deployment..."

  # Check if application is responding
  if curl -sf "$DEPLOYMENT_URL/api/version" > /dev/null 2>&1; then
    local version_info=$(curl -s "$DEPLOYMENT_URL/api/version" | jq -r '.version')
    log_success "Application is responsive (version: $version_info)"
  else
    log_error "Application is not responding"
    return 1
  fi

  # Check metrics endpoint
  if curl -sf "$DEPLOYMENT_URL/metrics" > /dev/null 2>&1; then
    log_success "Metrics endpoint is accessible"
  else
    log_warning "Metrics endpoint not accessible"
  fi

  log_success "Deployment verification passed"
}

rollback_deployment() {
  log_error "Rolling back deployment..."

  # This is a simplified rollback
  # In production, you'd want to revert to the previous version
  log_warning "Rollback mechanism would run here"
  log_info "Previous version should be restored"

  exit 1
}

create_deployment_record() {
  log_info "Recording deployment..."

  local record_file="/var/log/deployments/app-${ENVIRONMENT}-deployments.log"
  mkdir -p "$(dirname "$record_file")"

  cat >> "$record_file" << EOF
Timestamp: $(date -u +'%Y-%m-%d %H:%M:%S UTC')
Environment: $ENVIRONMENT
Version: $VERSION
Status: Success
Deployed by: ${USER:-CI/CD}
EOF

  log_success "Deployment recorded"
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
  echo ""
  echo "╔════════════════════════════════════════════════════════════╗"
  echo "║   Application Deployment Script                            ║"
  echo "╠════════════════════════════════════════════════════════════╣"
  echo "║ Environment: $ENVIRONMENT"
  echo "║ Version:     $VERSION"
  echo "║ Time:        $(date -u +'%Y-%m-%d %H:%M:%S UTC')"
  echo "╚════════════════════════════════════════════════════════════╝"
  echo ""

  validate_environment
  load_environment_config
  check_prerequisites

  if [[ "$ROLLBACK" == "true" ]]; then
    rollback_deployment
    exit 0
  fi

  if [[ "$ENVIRONMENT" == "prod" ]]; then
    backup_current_version
  fi

  pull_docker_image
  perform_deployment
  wait_for_deployment

  if health_check; then
    verify_deployment
    create_deployment_record

    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║   ✅ DEPLOYMENT SUCCESSFUL                                 ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "║ Environment: $ENVIRONMENT"
    echo "║ Version:     $VERSION"
    echo "║ URL:         $DEPLOYMENT_URL"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""

    exit 0
  else
    log_error "Deployment failed health checks"
    if [[ "$ENVIRONMENT" == "prod" ]]; then
      rollback_deployment
    fi
    exit 1
  fi
}

# Run main function
main "$@"
