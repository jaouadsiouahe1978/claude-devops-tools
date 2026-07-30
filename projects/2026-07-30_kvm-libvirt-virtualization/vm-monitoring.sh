#!/bin/bash
# Script de monitoring des VMs KVM
# Affiche les stats CPU, RAM, Disque et Réseau en temps réel

set -e

INTERVAL="${1:-2}"
VM_NAME="${2:-all}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

clear_screen() {
    clear
}

show_header() {
    echo -e "${YELLOW}=== KVM VMs Monitoring ===${NC}"
    echo "Temps: $(date '+%Y-%m-%d %H:%M:%S') | Intervalle: ${INTERVAL}s"
    echo -e "${BLUE}─────────────────────────────────────────────────────────${NC}"
}

get_vms() {
    if [[ "$VM_NAME" == "all" ]]; then
        virsh list --name --running 2>/dev/null || echo ""
    else
        if virsh list --name --running 2>/dev/null | grep -q "^${VM_NAME}$"; then
            echo "$VM_NAME"
        fi
    fi
}

format_bytes() {
    local bytes=$1
    if (( bytes >= 1073741824 )); then
        echo "$(awk "BEGIN {printf \"%.2f\", $bytes/1073741824}")GB"
    elif (( bytes >= 1048576 )); then
        echo "$(awk "BEGIN {printf \"%.2f\", $bytes/1048576}")MB"
    else
        echo "$((bytes / 1024))KB"
    fi
}

show_vm_stats() {
    local vm="$1"

    # État de la VM
    local state=$(virsh domstate "$vm" 2>/dev/null)

    # CPU et Mémoire
    local info=$(virsh dominfo "$vm" 2>/dev/null)
    local cpu_time=$(echo "$info" | grep "CPU time" | awk '{print $3}')
    local max_memory=$(echo "$info" | grep "Max memory" | awk '{print $3}')
    local used_memory=$(echo "$info" | grep "Used memory" | awk '{print $3}')
    local vcpus=$(echo "$info" | grep "CPU(s)" | awk '{print $2}')

    # Disque
    local disk_info=$(virsh domblkinfo "$vm" vda 2>/dev/null | grep "Capacity" | awk '{print $2}')

    # Couleur état
    local state_color="$GREEN"
    [[ "$state" != "running" ]] && state_color="$RED"

    printf "%-20s ${state_color}%-10s${NC} RAM: %5s / %5s MB | vCPU: %d | Disk: %s\n" \
        "$vm" "$state" "$used_memory" "$max_memory" "$vcpus" "$(format_bytes "$disk_info")"
}

# Boucle principale
while true; do
    clear_screen
    show_header

    local vms=$(get_vms)
    if [[ -z "$vms" ]]; then
        echo -e "${YELLOW}Aucune VM en cours d'exécution${NC}"
    else
        echo -e "${YELLOW}VMs actives:${NC}"
        echo ""
        while IFS= read -r vm; do
            [[ -n "$vm" ]] && show_vm_stats "$vm"
        done <<< "$vms"
    fi

    echo ""
    echo -e "${BLUE}─────────────────────────────────────────────────────────${NC}"
    echo -e "Mise à jour dans ${INTERVAL}s (Ctrl+C pour quitter)..."
    sleep "$INTERVAL"
done
