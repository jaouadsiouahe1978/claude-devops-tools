#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CHART_PATH="."
ENVIRONMENTS=("dev" "staging" "production")

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Validate Helm chart

OPTIONS:
    -c, --chart         Path to chart (default: .)
    -h, --help          Show this help message

EXAMPLES:
    ./validate.sh
    ./validate.sh -c /path/to/chart

EOF
    exit 0
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--chart)
            CHART_PATH="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            ;;
    esac
done

# Check Chart.yaml
if [[ ! -f "$CHART_PATH/Chart.yaml" ]]; then
    log_error "Chart.yaml not found at $CHART_PATH"
    exit 1
fi

log_info "Validating chart: $CHART_PATH"

ERRORS=0

# Lint chart with default values
log_info "Linting chart with default values..."
if helm lint "$CHART_PATH"; then
    log_success "Chart lint passed"
else
    log_error "Chart lint failed"
    ((ERRORS++))
fi

# Validate each environment
for ENV in "${ENVIRONMENTS[@]}"; do
    VALUES_FILE="$CHART_PATH/values-${ENV}.yaml"

    if [[ ! -f "$VALUES_FILE" ]]; then
        log_warn "Values file not found: $VALUES_FILE"
        continue
    fi

    log_info "Validating $ENV environment..."

    # Lint with environment values
    if helm lint "$CHART_PATH" --values "$VALUES_FILE"; then
        log_success "Lint passed for $ENV"
    else
        log_error "Lint failed for $ENV"
        ((ERRORS++))
    fi

    # Template test
    if helm template myapp "$CHART_PATH" --values "$VALUES_FILE" > /dev/null 2>&1; then
        log_success "Template generation passed for $ENV"
    else
        log_error "Template generation failed for $ENV"
        ((ERRORS++))
    fi

    # Generate manifests to check structure
    MANIFEST=$(helm template myapp "$CHART_PATH" --values "$VALUES_FILE")

    # Check for required fields
    if echo "$MANIFEST" | grep -q "kind: Deployment"; then
        log_success "Deployment template found for $ENV"
    else
        log_warn "Deployment template not found for $ENV"
    fi

    if echo "$MANIFEST" | grep -q "kind: Service"; then
        log_success "Service template found for $ENV"
    else
        log_warn "Service template not found for $ENV"
    fi
done

# Validate templates structure
log_info "Checking template structure..."

REQUIRED_TEMPLATES=("deployment.yaml" "service.yaml" "configmap.yaml" "_helpers.tpl")
for TEMPLATE in "${REQUIRED_TEMPLATES[@]}"; do
    if [[ -f "$CHART_PATH/templates/$TEMPLATE" ]]; then
        log_success "Template found: $TEMPLATE"
    else
        log_warn "Template not found: $TEMPLATE"
    fi
done

# Summary
echo ""
if [[ $ERRORS -eq 0 ]]; then
    log_success "All validations passed!"
    exit 0
else
    log_error "Validation failed with $ERRORS errors"
    exit 1
fi
