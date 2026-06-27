#!/bin/bash
# scripts/system-health-check.sh
# System health check: CPU, memory, disk, network
# Usage: ./system-health-check.sh [--cpu-alert 80] [--mem-alert 85] [--disk-alert 90]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

# Default alert thresholds
CPU_ALERT=80
MEM_ALERT=85
DISK_ALERT=90

# Colors for status
STATUS_OK="${GREEN}✓${NC}"
STATUS_WARN="${YELLOW}⚠${NC}"
STATUS_CRIT="${RED}✗${NC}"

show_usage() {
  cat <<EOF
Usage: $0 [OPTIONS]

System health check with configurable alerts.

OPTIONS:
  --cpu-alert PERCENT     CPU alert threshold (0-100, default: 80)
  --mem-alert PERCENT     Memory alert threshold (0-100, default: 85)
  --disk-alert PERCENT    Disk alert threshold (0-100, default: 90)
  --no-color             Disable colored output
  --help                 Show this help message

EXAMPLES:
  $0                                      # Default thresholds
  $0 --cpu-alert 75 --mem-alert 80       # Custom thresholds
  $0 --no-color                          # For cron/logging

EOF
}

# Parse arguments
NO_COLOR=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --cpu-alert)
      CPU_ALERT="$2"
      is_percentage "$CPU_ALERT" || exit 1
      shift 2
      ;;
    --mem-alert)
      MEM_ALERT="$2"
      is_percentage "$MEM_ALERT" || exit 1
      shift 2
      ;;
    --disk-alert)
      DISK_ALERT="$2"
      is_percentage "$DISK_ALERT" || exit 1
      shift 2
      ;;
    --no-color)
      NO_COLOR=1
      shift
      ;;
    --help)
      show_usage
      exit 0
      ;;
    *)
      log_error "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Disable colors if requested
if [[ $NO_COLOR -eq 1 ]]; then
  RED="" GREEN="" YELLOW="" BLUE="" NC=""
  STATUS_OK="OK" STATUS_WARN="WARN" STATUS_CRIT="CRIT"
fi

# ===== CPU CHECK =====

get_cpu_usage() {
  local cpu_usage
  cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2)}')
  echo "$cpu_usage"
}

check_cpu() {
  local cpu_usage
  cpu_usage=$(get_cpu_usage)

  local status="$STATUS_OK"
  local status_text="OK"

  if [[ $cpu_usage -ge $CPU_ALERT ]]; then
    status="$STATUS_CRIT"
    status_text="CRITICAL"
  elif [[ $cpu_usage -ge $((CPU_ALERT - 10)) ]]; then
    status="$STATUS_WARN"
    status_text="WARNING"
  fi

  printf "CPU Usage        : %3d%% %s %s\n" "$cpu_usage" "$(progress_bar "$cpu_usage" 100)" "$status $status_text"
  return 0
}

# ===== MEMORY CHECK =====

get_memory_usage() {
  local total mem_used percentage
  total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
  mem_used=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
  mem_used=$((total - mem_used))
  percentage=$((mem_used * 100 / total))
  echo "$percentage"
}

check_memory() {
  local mem_percent
  mem_percent=$(get_memory_usage)

  local status="$STATUS_OK"
  local status_text="OK"

  if [[ $mem_percent -ge $MEM_ALERT ]]; then
    status="$STATUS_CRIT"
    status_text="CRITICAL"
  elif [[ $mem_percent -ge $((MEM_ALERT - 10)) ]]; then
    status="$STATUS_WARN"
    status_text="WARNING"
  fi

  printf "Memory Usage     : %3d%% %s %s\n" "$mem_percent" "$(progress_bar "$mem_percent" 100)" "$status $status_text"
  return 0
}

# ===== DISK CHECK =====

check_disk() {
  local disk_usage
  disk_usage=$(get_disk_usage_percent "/")

  local status="$STATUS_OK"
  local status_text="OK"

  if [[ $disk_usage -ge $DISK_ALERT ]]; then
    status="$STATUS_CRIT"
    status_text="CRITICAL"
  elif [[ $disk_usage -ge $((DISK_ALERT - 10)) ]]; then
    status="$STATUS_WARN"
    status_text="WARNING"
  fi

  printf "Disk Usage (/)   : %3d%% %s %s\n" "$disk_usage" "$(progress_bar "$disk_usage" 100)" "$status $status_text"
  return 0
}

# ===== NETWORK CHECK =====

check_network() {
  local net_stats
  net_stats=$(cat /proc/net/dev | grep -E 'eth0|wlan0|ens' | head -1)

  if [[ -n "$net_stats" ]]; then
    local bytes_in bytes_out
    bytes_in=$(echo "$net_stats" | awk '{print $2}')
    bytes_out=$(echo "$net_stats" | awk '{print $10}')

    # Convert to human readable
    local in_mb out_mb
    in_mb=$(echo "scale=1; $bytes_in / 1048576" | bc)
    out_mb=$(echo "scale=1; $bytes_out / 1048576" | bc)

    printf "Network IO       : ↓ %6.1f MB ↑ %6.1f MB %s\n" "$in_mb" "$out_mb" "$STATUS_OK"
  else
    printf "Network IO       : No interface found %s\n" "$STATUS_WARN"
  fi
  return 0
}

# ===== LOAD AVERAGE CHECK =====

check_load() {
  local load_avg cpu_count
  load_avg=$(cut -d' ' -f1 /proc/loadavg)
  cpu_count=$(nproc)

  local status="$STATUS_OK"
  local load_percent=$((${load_avg%.*} * 100 / cpu_count))

  if (( $(echo "$load_avg > $cpu_count * 1.5" | bc -l) )); then
    status="$STATUS_WARN"
  elif (( $(echo "$load_avg > $cpu_count * 2.0" | bc -l) )); then
    status="$STATUS_CRIT"
  fi

  printf "Load Average     : %4.2f (%d cores) %s\n" "$load_avg" "$cpu_count" "$status"
  return 0
}

# ===== MAIN REPORT =====

generate_report() {
  print_header "SYSTEM HEALTH CHECK REPORT"
  echo ""

  check_cpu
  check_memory
  check_disk
  echo ""
  check_network
  check_load
  echo ""

  # Overall status
  local overall_status="OK"
  local cpu_usage mem_percent disk_usage

  cpu_usage=$(get_cpu_usage)
  mem_percent=$(get_memory_usage)
  disk_usage=$(get_disk_usage_percent "/")

  if [[ $cpu_usage -ge $CPU_ALERT ]] || [[ $mem_percent -ge $MEM_ALERT ]] || [[ $disk_usage -ge $DISK_ALERT ]]; then
    overall_status="CRITICAL"
  elif [[ $cpu_usage -ge $((CPU_ALERT - 10)) ]] || [[ $mem_percent -ge $((MEM_ALERT - 10)) ]] || [[ $disk_usage -ge $((DISK_ALERT - 10)) ]]; then
    overall_status="WARNING"
  fi

  case "$overall_status" in
    OK)
      echo -e "${GREEN}Status: ✅ OK${NC} (All systems nominal)"
      ;;
    WARNING)
      echo -e "${YELLOW}Status: ⚠️  WARNING${NC} (Some metrics elevated)"
      ;;
    CRITICAL)
      echo -e "${RED}Status: 🚨 CRITICAL${NC} (Action required!)${NC}"
      ;;
  esac

  echo ""
  printf "Checked at: %s\n" "$(date '+%Y-%m-%d %H:%M:%S UTC' -u)"
}

# ===== MAIN EXECUTION =====

generate_report
