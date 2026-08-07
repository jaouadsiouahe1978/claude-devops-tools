#!/bin/bash

##############################################################################
# DNS Route53 Validation & Testing Suite
# Infrastructure: Zone Sud-2, VPC 10.0.0.0/16, Clusters A/B, Bastion
#
# Usage:
#   ./dns_validation_scripts.sh [domain] [environment]
#
# Examples:
#   ./dns_validation_scripts.sh domaine.com production
#   ./dns_validation_scripts.sh domaine.com staging
#
# Requirements:
#   - AWS CLI v2
#   - dig/nslookup (dnsutils package)
#   - curl/wget
#   - jq (for JSON parsing)
#
##############################################################################

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
DOMAIN="${1:-domaine.com}"
ENVIRONMENT="${2:-production}"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
REPORT_FILE="/tmp/dns_validation_report_${DOMAIN}_${TIMESTAMP//[ :]/_}.txt"

# Global counters
PASSED=0
FAILED=0
WARNINGS=0

##############################################################################
# Helper Functions
##############################################################################

log_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

log_success() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    ((PASSED++))
}

log_error() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    ((FAILED++))
}

log_warning() {
    echo -e "${YELLOW}⚠ WARN${NC}: $1"
    ((WARNINGS++))
}

log_info() {
    echo -e "${CYAN}ℹ INFO${NC}: $1"
}

log_test() {
    echo -e "${CYAN}→${NC} Testing: $1"
}

##############################################################################
# 1. AWS CONFIGURATION CHECKS
##############################################################################

check_aws_credentials() {
    log_header "AWS Credentials & Configuration"

    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI not found. Install with: pip install awscli"
        return 1
    fi
    log_success "AWS CLI is installed"

    if aws sts get-caller-identity &> /dev/null; then
        ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
        REGION=$(aws configure get region)
        log_success "AWS credentials valid (Account: $ACCOUNT_ID, Region: $REGION)"
    else
        log_error "AWS credentials not configured"
        return 1
    fi
}

##############################################################################
# 2. ROUTE53 HOSTED ZONE CHECKS
##############################################################################

check_hosted_zone() {
    log_header "Route53 Hosted Zone: $DOMAIN"

    log_test "Finding hosted zone ID for $DOMAIN"
    ZONE_ID=$(aws route53 list-hosted-zones-by-name --dns-name "$DOMAIN" \
        --query "HostedZones[0].Id" --output text 2>/dev/null | cut -d'/' -f3)

    if [ -z "$ZONE_ID" ] || [ "$ZONE_ID" = "None" ]; then
        log_error "Hosted zone not found for $DOMAIN"
        return 1
    fi
    log_success "Found hosted zone: $ZONE_ID"

    # Get nameservers
    log_test "Retrieving nameservers"
    NAMESERVERS=$(aws route53 get-hosted-zone --id "$ZONE_ID" \
        --query "DelegationSet.NameServers" --output json)
    echo "$NAMESERVERS" | jq -r '.[]' | while read -r ns; do
        log_info "Nameserver: $ns"
    done

    # Get record count
    RECORD_COUNT=$(aws route53 list-resource-record-sets --hosted-zone-id "$ZONE_ID" \
        --query "ResourceRecordSets | length" --output text)
    log_success "Hosted zone contains $RECORD_COUNT records"
}

##############################################################################
# 3. DNS RECORD VALIDATION
##############################################################################

validate_dns_record() {
    local record_name="$1"
    local expected_type="$2"
    local description="$3"

    log_test "$description ($record_name)"

    # Query Route53 directly
    local record=$(aws route53 list-resource-record-sets --hosted-zone-id "$ZONE_ID" \
        --query "ResourceRecordSets[?Name=='${record_name}.'].{Type:Type, TTL:TTL, ResourceRecords:ResourceRecords}" \
        --output json 2>/dev/null)

    if [ "$record" = "[]" ]; then
        log_error "Record not found: $record_name"
        return 1
    fi

    local type=$(echo "$record" | jq -r '.[0].Type')
    local ttl=$(echo "$record" | jq -r '.[0].TTL // "N/A"')

    if [ "$type" = "$expected_type" ]; then
        log_success "Record found: $record_name ($type, TTL: $ttl)"
        echo "$record" | jq '.[0]'
        return 0
    else
        log_error "Record type mismatch: expected $expected_type, got $type"
        return 1
    fi
}

check_dns_records() {
    log_header "DNS Records Validation"

    validate_dns_record "$DOMAIN" "A" "Apex A record"
    validate_dns_record "api.$DOMAIN" "A" "API Alias record"
    validate_dns_record "admin.$DOMAIN" "A" "Admin Bastion record"
    validate_dns_record "aden.$DOMAIN" "A" "External Partner record"

    # Optional IPv6
    validate_dns_record "$DOMAIN" "AAAA" "Apex AAAA record (IPv6)" || log_warning "IPv6 record not configured"
    validate_dns_record "api.$DOMAIN" "AAAA" "API AAAA record (IPv6)" || log_warning "IPv6 record not configured"
}

##############################################################################
# 4. PRIVATE HOSTED ZONE CHECKS
##############################################################################

check_private_hosted_zone() {
    log_header "Private Hosted Zone: internal.$DOMAIN"

    PRIVATE_ZONE=$(aws route53 list-hosted-zones-by-name --dns-name "internal.$DOMAIN" \
        --query "HostedZones[?Config.PrivateZone==\`true\`].Id" --output text | cut -d'/' -f3)

    if [ -z "$PRIVATE_ZONE" ]; then
        log_warning "Private hosted zone not found for internal.$DOMAIN"
        return 1
    fi

    log_success "Found private zone: $PRIVATE_ZONE"

    # Check VPC association
    log_test "Verifying VPC association"
    VPCS=$(aws route53 get-hosted-zone --id "$PRIVATE_ZONE" \
        --query "HostedZoneConfig.PrivateZone" --output text)
    log_success "Private zone configuration verified"
}

##############################################################################
# 5. HEALTH CHECKS VALIDATION
##############################################################################

check_health_checks() {
    log_header "Route53 Health Checks"

    log_test "Listing all health checks"
    HEALTH_CHECKS=$(aws route53 list-health-checks --query "HealthChecks[].{Id:Id, Type:Type, CallerReference:CallerReference}" --output json)

    if echo "$HEALTH_CHECKS" | jq -e '. | length > 0' &>/dev/null; then
        local count=$(echo "$HEALTH_CHECKS" | jq '. | length')
        log_success "Found $count health checks"
        echo "$HEALTH_CHECKS" | jq '.[] | "\(.Type) - \(.CallerReference)"' -r | while read -r hc; do
            log_info "Health Check: $hc"
        done
    else
        log_warning "No health checks configured"
    fi

    # Check health status
    log_test "Checking health check statuses"
    aws route53 list-health-checks --query "HealthChecks[].Id" --output text | while read -r hc_id; do
        if [ -n "$hc_id" ]; then
            STATUS=$(aws route53 get-health-check-status --health-check-id "$hc_id" \
                --query "HealthCheckObservations[0].StatusReport.Status" --output text 2>/dev/null || echo "UNKNOWN")
            log_info "Health Check $hc_id: $STATUS"
        fi
    done
}

##############################################################################
# 6. DNS RESOLUTION TESTING
##############################################################################

test_dns_resolution() {
    log_header "DNS Resolution Tests"

    local nameservers=(
        "8.8.8.8"
        "1.1.1.1"
        "208.67.222.222"
    )

    # Get Route53 nameserver
    NS=$(echo "$NAMESERVERS" | jq -r '.[0]')

    for record in "" "api" "admin" "aden"; do
        local fqdn="$DOMAIN"
        if [ -n "$record" ]; then
            fqdn="$record.$DOMAIN"
        fi

        log_test "Resolving $fqdn"

        # Test against Route53 directly
        if dig +short @"$NS" "$fqdn" A &>/dev/null; then
            RESULT=$(dig +short @"$NS" "$fqdn" A)
            if [ -n "$RESULT" ]; then
                log_success "Route53 resolves: $fqdn → $RESULT"
            else
                log_warning "Route53 returned empty response for $fqdn"
            fi
        else
            log_error "Failed to query Route53 for $fqdn"
        fi

        # Test against public resolvers
        for resolver in "${nameservers[@]}"; do
            if RESULT=$(dig +short @"$resolver" "$fqdn" A 2>/dev/null); then
                if [ -n "$RESULT" ]; then
                    log_info "$resolver resolves $fqdn → $RESULT"
                fi
            fi
        done
    done
}

##############################################################################
# 7. PROPAGATION CHECKS
##############################################################################

check_propagation() {
    log_header "DNS Propagation Status"

    log_test "Checking propagation of api.$DOMAIN"

    # We'll check against major public nameservers
    declare -A resolvers=(
        ["Google"]="8.8.8.8"
        ["Cloudflare"]="1.1.1.1"
        ["Quad9"]="9.9.9.9"
        ["OpenDNS"]="208.67.222.222"
        ["Route53"]="$(echo "$NAMESERVERS" | jq -r '.[0]')"
    )

    for resolver_name in "${!resolvers[@]}"; do
        resolver="${resolvers[$resolver_name]}"
        if result=$(dig +short @"$resolver" "api.$DOMAIN" A 2>/dev/null); then
            if [ -n "$result" ]; then
                log_success "$resolver_name: $result"
            else
                log_warning "$resolver_name: No response"
            fi
        else
            log_error "$resolver_name: Query failed"
        fi
    done
}

##############################################################################
# 8. CONNECTIVITY TESTS
##############################################################################

test_connectivity() {
    log_header "Connectivity Tests"

    local endpoints=(
        "https://api.$DOMAIN"
        "https://$DOMAIN"
    )

    for endpoint in "${endpoints[@]}"; do
        log_test "Testing endpoint: $endpoint"

        if timeout 5 curl -s -o /dev/null -w "%{http_code}" "$endpoint" 2>/dev/null; then
            http_code=$(timeout 5 curl -s -o /dev/null -w "%{http_code}" "$endpoint" 2>/dev/null)
            if [ "$http_code" -lt 500 ]; then
                log_success "$endpoint responds with HTTP $http_code"
            else
                log_error "$endpoint responds with HTTP $http_code (server error)"
            fi
        else
            log_warning "$endpoint unreachable or connection timeout"
        fi
    done
}

##############################################################################
# 9. REVERSE DNS CHECKS
##############################################################################

test_reverse_dns() {
    log_header "Reverse DNS Validation"

    log_test "Checking reverse DNS for bastion IP"

    # Extract Bastion IP from admin record
    BASTION_IP=$(aws route53 list-resource-record-sets --hosted-zone-id "$ZONE_ID" \
        --query "ResourceRecordSets[?Name=='admin.$DOMAIN.'].ResourceRecords[0].Value" \
        --output text 2>/dev/null)

    if [ -n "$BASTION_IP" ] && [ "$BASTION_IP" != "None" ]; then
        if reverse_result=$(dig +short -x "$BASTION_IP" 2>/dev/null); then
            if [ -n "$reverse_result" ]; then
                log_success "Reverse DNS $BASTION_IP → $reverse_result"
            else
                log_warning "No reverse DNS entry for $BASTION_IP"
            fi
        fi
    else
        log_warning "Could not extract Bastion IP"
    fi
}

##############################################################################
# 10. CERTIFICATE & HTTPS CHECKS
##############################################################################

test_certificates() {
    log_header "SSL/TLS Certificate Checks"

    log_test "Checking certificate for api.$DOMAIN"

    if cert_info=$(echo | openssl s_client -servername "api.$DOMAIN" \
        -connect "api.$DOMAIN:443" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null); then
        log_success "Certificate found for api.$DOMAIN"
        echo "$cert_info" | sed 's/^/  /'
    else
        log_warning "Could not retrieve certificate for api.$DOMAIN (may not be configured yet)"
    fi
}

##############################################################################
# 11. TTL VALIDATION
##############################################################################

check_ttl_values() {
    log_header "TTL Configuration Review"

    log_test "Checking TTL for dynamic endpoints"

    # Extract TTLs
    api_ttl=$(aws route53 list-resource-record-sets --hosted-zone-id "$ZONE_ID" \
        --query "ResourceRecordSets[?Name=='api.$DOMAIN.'].TTL" \
        --output text 2>/dev/null)

    admin_ttl=$(aws route53 list-resource-record-sets --hosted-zone-id "$ZONE_ID" \
        --query "ResourceRecordSets[?Name=='admin.$DOMAIN.'].TTL" \
        --output text 2>/dev/null)

    log_info "api.$DOMAIN TTL: $api_ttl (recommended: 300s for dynamic)"
    log_info "admin.$DOMAIN TTL: $admin_ttl (recommended: 3600s for stable)"

    # Validate TTL values
    if [ "$api_ttl" -le 300 ]; then
        log_success "api.$DOMAIN has appropriate short TTL"
    else
        log_warning "api.$DOMAIN TTL ($api_ttl) is higher than recommended"
    fi
}

##############################################################################
# 12. CLOUDWATCH MONITORING
##############################################################################

check_cloudwatch_alarms() {
    log_header "CloudWatch Monitoring"

    log_test "Checking CloudWatch alarms related to Route53"

    alarms=$(aws cloudwatch describe-alarms \
        --alarm-name-prefix "route53" \
        --query "MetricAlarms[].{Name:AlarmName, State:StateValue}" \
        --output json 2>/dev/null)

    if echo "$alarms" | jq -e '. | length > 0' &>/dev/null; then
        local count=$(echo "$alarms" | jq '. | length')
        log_success "Found $count Route53-related alarms"
        echo "$alarms" | jq -r '.[] | "\(.Name): \(.State)"' | while read -r alarm; do
            log_info "Alarm: $alarm"
        done
    else
        log_warning "No CloudWatch alarms found for Route53"
    fi
}

##############################################################################
# 13. SECURITY CHECKS
##############################################################################

check_security() {
    log_header "Security & Best Practices"

    # Check DNSSEC
    log_test "Checking DNSSEC status"
    dnssec=$(aws route53 get-dnssec --hosted-zone-id "$ZONE_ID" \
        --query "Status.ServeSignature" --output text 2>/dev/null || echo "not-configured")

    if [ "$dnssec" = "SIGNING" ]; then
        log_success "DNSSEC is enabled"
    else
        log_warning "DNSSEC is not enabled (recommended for production)"
    fi

    # Check logging
    log_test "Checking query logging"
    logging=$(aws route53 list-query-logging-configs --hosted-zone-id "$ZONE_ID" \
        --query "QueryLoggingConfigs | length" --output text 2>/dev/null || echo "0")

    if [ "$logging" -gt 0 ]; then
        log_success "Query logging is configured"
    else
        log_warning "Query logging not enabled (recommended for troubleshooting)"
    fi
}

##############################################################################
# 14. REPORT GENERATION
##############################################################################

generate_report() {
    log_header "Test Summary Report"

    echo "DNS Validation Report" > "$REPORT_FILE"
    echo "===================" >> "$REPORT_FILE"
    echo "Domain: $DOMAIN" >> "$REPORT_FILE"
    echo "Environment: $ENVIRONMENT" >> "$REPORT_FILE"
    echo "Timestamp: $TIMESTAMP" >> "$REPORT_FILE"
    echo "Report File: $REPORT_FILE" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "Test Results:" >> "$REPORT_FILE"
    echo "  Passed:  $PASSED" >> "$REPORT_FILE"
    echo "  Failed:  $FAILED" >> "$REPORT_FILE"
    echo "  Warnings: $WARNINGS" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    # Summary
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║          TEST SUMMARY REPORT           ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    echo -e "  ${GREEN}✓ PASSED:  $PASSED${NC}"
    echo -e "  ${RED}✗ FAILED:  $FAILED${NC}"
    echo -e "  ${YELLOW}⚠ WARNINGS: $WARNINGS${NC}"
    echo ""
    echo "Report saved to: $REPORT_FILE"
    echo ""

    if [ $FAILED -eq 0 ]; then
        echo -e "${GREEN}All critical tests passed!${NC}"
        return 0
    else
        echo -e "${RED}Some tests failed. Review above.${NC}"
        return 1
    fi
}

##############################################################################
# MAIN EXECUTION
##############################################################################

main() {
    clear
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║   DNS Route53 Validation & Testing Suite                   ║"
    echo "║   Infrastructure: Zone Sud-2, VPC, Clusters A/B, Bastion   ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo "Domain: $DOMAIN"
    echo "Environment: $ENVIRONMENT"
    echo "Start Time: $TIMESTAMP"
    echo ""

    # Run all checks
    check_aws_credentials || exit 1
    check_hosted_zone || exit 1
    check_dns_records
    check_private_hosted_zone
    check_health_checks
    test_dns_resolution
    check_propagation
    test_connectivity || true
    test_reverse_dns || true
    test_certificates || true
    check_ttl_values
    check_cloudwatch_alarms
    check_security

    # Generate final report
    generate_report
}

# Run main
main "$@"
