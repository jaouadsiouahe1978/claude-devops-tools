#!/bin/bash
# scripts/app-deployment.sh
# Simple but robust application deployment script

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

REPO_URL=""
BRANCH="main"
TARGET_DIR=""
HEALTHCHECK_URL=""
BUILD_CMD=""
BACKUP_DIR=""

show_usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

Deploy application from Git repository.

OPTIONS:
  --repo URL          Git repository URL (required)
  --branch BRANCH     Git branch to deploy (default: main)
  --target DIR        Target deployment directory (required)
  --healthcheck URL   Health check URL (e.g., http://localhost:8080/health)
  --build CMD         Build command (e.g., 'make build' or 'docker build')
  --dry-run          Show what would be done
  --help             Show this help

EXAMPLES:
  $0 --repo https://github.com/user/app.git \\
     --target /opt/myapp \\
     --healthcheck http://localhost:8080/health

EOF
}

DRY_RUN=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) REPO_URL="$2"; shift 2 ;;
    --branch) BRANCH="$2"; shift 2 ;;
    --target) TARGET_DIR="$2"; shift 2 ;;
    --healthcheck) HEALTHCHECK_URL="$2"; shift 2 ;;
    --build) BUILD_CMD="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    --help) show_usage; exit 0 ;;
    *) log_error "Unknown option: $1"; exit 1 ;;
  esac
done

# Validation
if [[ -z "$REPO_URL" || -z "$TARGET_DIR" ]]; then
  log_error "Missing required options: --repo and --target"
  show_usage
  exit 1
fi

require_command "git"

print_header "APPLICATION DEPLOYMENT"
log_info "Repository: $REPO_URL"
log_info "Branch: $BRANCH"
log_info "Target: $TARGET_DIR"

# Prepare backup directory
BACKUP_DIR="${TARGET_DIR}.backup.$(date +%s)"

cleanup_on_failure() {
  if [[ -d "$BACKUP_DIR" && $DRY_RUN -eq 0 ]]; then
    log_warning "Deployment failed, rolling back..."
    rm -rf "$TARGET_DIR"
    mv "$BACKUP_DIR" "$TARGET_DIR"
    log_success "Rollback completed"
  fi
}

register_cleanup cleanup_on_failure

# ===== STEP 1: BACKUP =====

backup_current() {
  print_section "Step 1: Backing up current version"

  if [[ ! -d "$TARGET_DIR" ]]; then
    log_info "No existing deployment to backup"
    return 0
  fi

  if [[ $DRY_RUN -eq 1 ]]; then
    log_info "[DRY-RUN] Would backup $TARGET_DIR to $BACKUP_DIR"
    return 0
  fi

  log_info "Creating backup at: $BACKUP_DIR"
  cp -r "$TARGET_DIR" "$BACKUP_DIR"
  log_success "Backup created"
}

# ===== STEP 2: FETCH/CLONE =====

fetch_code() {
  print_section "Step 2: Fetching code"

  if [[ $DRY_RUN -eq 1 ]]; then
    log_info "[DRY-RUN] Would clone/pull $REPO_URL"
    return 0
  fi

  if [[ -d "$TARGET_DIR/.git" ]]; then
    log_info "Repository exists, updating..."
    (cd "$TARGET_DIR" && git fetch origin && git checkout "$BRANCH" && git pull origin "$BRANCH") || {
      log_error "Failed to update repository"
      return 1
    }
  else
    log_info "Cloning repository..."
    git clone --branch "$BRANCH" "$REPO_URL" "$TARGET_DIR" || {
      log_error "Failed to clone repository"
      return 1
    }
  fi

  log_success "Code fetched successfully"
}

# ===== STEP 3: BUILD =====

build_app() {
  print_section "Step 3: Building application"

  if [[ -z "$BUILD_CMD" ]]; then
    log_info "No build command specified, skipping..."
    return 0
  fi

  if [[ $DRY_RUN -eq 1 ]]; then
    log_info "[DRY-RUN] Would run: $BUILD_CMD"
    return 0
  fi

  log_info "Running build: $BUILD_CMD"
  (cd "$TARGET_DIR" && eval "$BUILD_CMD") || {
    log_error "Build failed"
    return 1
  }

  log_success "Build completed"
}

# ===== STEP 4: HEALTH CHECK =====

health_check() {
  print_section "Step 4: Health check"

  if [[ -z "$HEALTHCHECK_URL" ]]; then
    log_info "No health check configured"
    return 0
  fi

  if [[ $DRY_RUN -eq 1 ]]; then
    log_info "[DRY-RUN] Would check: $HEALTHCHECK_URL"
    return 0
  fi

  log_info "Checking: $HEALTHCHECK_URL"

  # Retry health check with backoff
  local max_attempts=10
  local attempt=1

  while [[ $attempt -le $max_attempts ]]; do
    if curl -sf "$HEALTHCHECK_URL" >/dev/null 2>&1; then
      log_success "Health check passed"
      return 0
    fi

    log_warning "Health check failed (attempt $attempt/$max_attempts)"
    if [[ $attempt -lt $max_attempts ]]; then
      sleep $((2 ** (attempt - 1)))  # Exponential backoff
    fi

    ((attempt++))
  done

  log_error "Health check failed after $max_attempts attempts"
  return 1
}

# ===== MAIN DEPLOYMENT =====

main() {
  backup_current
  fetch_code
  build_app
  health_check

  print_header "DEPLOYMENT COMPLETE"
  log_success "Application deployed successfully"

  # Cleanup backup if deployment was successful
  if [[ -d "$BACKUP_DIR" && $DRY_RUN -eq 0 ]]; then
    log_info "Removing old backup: $BACKUP_DIR"
    rm -rf "$BACKUP_DIR"
  fi
}

main
