#!/bin/bash
# Ansible Deployment Helper Script

set -e

COLOR_GREEN='\033[0;32m'
COLOR_BLUE='\033[0;34m'
COLOR_YELLOW='\033[1;33m'
COLOR_RED='\033[0;31m'
NC='\033[0m'

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INVENTORY="${PROJECT_DIR}/inventory.yml"
PLAYBOOK="${PROJECT_DIR}/playbooks/site.yml"

# Logging functions
info() { echo -e "${COLOR_BLUE}[INFO]${NC} $1"; }
success() { echo -e "${COLOR_GREEN}[✓]${NC} $1"; }
warn() { echo -e "${COLOR_YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${COLOR_RED}[ERROR]${NC} $1"; }

# Check prerequisites
check_prerequisites() {
    info "Checking prerequisites..."

    if ! command -v ansible &> /dev/null; then
        error "Ansible is not installed. Install with: pip install ansible"
        exit 1
    fi

    if [ ! -f "$INVENTORY" ]; then
        error "Inventory file not found: $INVENTORY"
        exit 1
    fi

    success "Prerequisites check passed"
}

# Test connectivity
test_connectivity() {
    info "Testing connectivity to all hosts..."
    ansible all -i "$INVENTORY" -m ping -q
    success "All hosts are reachable"
}

# Syntax check
syntax_check() {
    info "Checking playbook syntax..."
    ansible-playbook "$PLAYBOOK" --syntax-check -q
    success "Syntax check passed"
}

# Dry-run
dry_run() {
    info "Running in check mode (no changes will be made)..."
    ansible-playbook "$PLAYBOOK" -i "$INVENTORY" --check -v
    success "Dry-run completed"
}

# Full deployment
deploy() {
    info "Starting full deployment..."

    read -p "Are you sure you want to deploy to production? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        warn "Deployment cancelled"
        exit 0
    fi

    ansible-playbook "$PLAYBOOK" -i "$INVENTORY" -v
    success "Deployment completed successfully"
}

# Selective deployment
deploy_component() {
    local component=$1
    info "Deploying $component..."

    if [ -f "${PROJECT_DIR}/playbooks/${component}.yml" ]; then
        ansible-playbook "${PROJECT_DIR}/playbooks/${component}.yml" -i "$INVENTORY" -v
        success "$component deployment completed"
    else
        error "Playbook not found for component: $component"
        exit 1
    fi
}

# Validation
validate() {
    info "Running validation tests..."
    ansible-playbook "${PROJECT_DIR}/tests/test-connection.yml" -i "$INVENTORY" -v
    success "Validation completed"
}

# Help
show_help() {
    cat << EOF
Usage: $0 [COMMAND]

Commands:
    check           Check prerequisites and connectivity
    syntax          Check playbook syntax only
    dry-run         Run deployment in check mode (no changes)
    deploy          Full stack deployment
    webservers      Deploy webservers only
    database        Deploy database only
    monitoring      Deploy monitoring only
    validate        Run validation tests
    help            Show this help message

Examples:
    $0 check              # Verify setup
    $0 syntax             # Check YAML syntax
    $0 dry-run            # Simulate deployment
    $0 deploy             # Execute full deployment
    $0 webservers         # Deploy webservers component
    $0 validate           # Run tests

EOF
}

# Main
main() {
    local command=${1:-help}

    case "$command" in
        check)
            check_prerequisites
            test_connectivity
            ;;
        syntax)
            check_prerequisites
            syntax_check
            ;;
        dry-run)
            check_prerequisites
            syntax_check
            dry_run
            ;;
        deploy)
            check_prerequisites
            syntax_check
            deploy
            ;;
        webservers|database|monitoring)
            check_prerequisites
            deploy_component "$command"
            ;;
        validate)
            validate
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
