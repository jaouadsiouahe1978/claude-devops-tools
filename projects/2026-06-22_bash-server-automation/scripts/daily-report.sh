#!/bin/bash

################################################################################
# Daily Report - Rapport quotidien complet du serveur
# Usage: ./daily-report.sh ou via cron: 0 0 * * * /path/to/daily-report.sh
################################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/config/server-config.sh"
source "${SCRIPT_DIR}/modules/logging.sh"
source "${SCRIPT_DIR}/modules/system.sh"
source "${SCRIPT_DIR}/modules/disk.sh"
source "${SCRIPT_DIR}/modules/packages.sh"
source "${SCRIPT_DIR}/modules/services.sh"

################################################################################
# Générer le rapport
################################################################################
generate_report() {
    local report_file="/tmp/daily-report-$(date +%Y%m%d).txt"

    cat > "$report_file" <<EOF
================================================================================
                    RAPPORT QUOTIDIEN SERVEUR
                    $(date '+%Y-%m-%d %H:%M:%S')
================================================================================

1. INFORMATIONS SYSTÈME
================================================================================
Hostname: $(hostname)
Kernel:   $(uname -r)
OS:       $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)
Uptime:   $(uptime -p)

2. CPU ET CHARGE
================================================================================
Nombre de CPUs: $(nproc)
Modèle CPU:     $(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | xargs)
Load Average:   $(uptime | awk -F'load average:' '{print $2}')

Top 5 processus par CPU:
EOF

    ps aux --sort=-%cpu | head -6 | tail -5 | awk '{printf "  %-8s %-6s %-6s %s\n", $1, $3, $4, $11}' >> "$report_file"

    cat >> "$report_file" <<EOF

3. MÉMOIRE
================================================================================
EOF

    free -h | awk 'NR==1 {printf "%-10s %s\n", "Type", $0} NR>=2 {printf "%-10s %s\n", $1, $0}' >> "$report_file"

    local mem_percent=$(free | grep Mem | awk '{print int($3/$2 * 100)}')
    echo "Utilisation: ${mem_percent}%" >> "$report_file"

    cat >> "$report_file" <<EOF

Top 5 processus par Mémoire:
EOF

    ps aux --sort=-%mem | head -6 | tail -5 | awk '{printf "  %-8s %-6s %-6s %s\n", $1, $3, $4, $11}' >> "$report_file"

    cat >> "$report_file" <<EOF

4. DISQUE
================================================================================
EOF

    df -h | awk 'NR==1 || NF' | sed 's/^/  /' >> "$report_file"

    cat >> "$report_file" <<EOF

Répertoires les plus volumineux:
EOF

    du -sh /home/* /var/* /opt/* 2>/dev/null | sort -rh | head -10 | sed 's/^/  /' >> "$report_file"

    cat >> "$report_file" <<EOF

5. RÉSEAU
================================================================================
Interfaces actives:
EOF

    ip -br addr 2>/dev/null | sed 's/^/  /' >> "$report_file"

    cat >> "$report_file" <<EOF

Connexions actives:
EOF

    if command -v ss &>/dev/null; then
        ss -tan | head -10 | tail -9 | sed 's/^/  /' >> "$report_file"
    fi

    cat >> "$report_file" <<EOF

6. SERVICES SYSTÈME
================================================================================
EOF

    systemctl list-units --type=service --state=running --no-pager | grep -v "^--" | tail -n +2 | sed 's/^/  /' >> "$report_file"

    cat >> "$report_file" <<EOF

7. PAQUETS
================================================================================
Total de paquets installés: $(count_installed_packages)

Derniers paquets listés:
EOF

    if command -v dpkg &>/dev/null; then
        dpkg -l 2>/dev/null | grep '^ii' | awk '{print $2, "(" $3 ")"}' | tail -20 | sed 's/^/  /' >> "$report_file"
    fi

    cat >> "$report_file" <<EOF

8. LOGS SYSTÈME (derniers erreurs)
================================================================================
EOF

    grep ERROR "$LOG_FILE" 2>/dev/null | tail -20 | sed 's/^/  /' >> "$report_file"

    cat >> "$report_file" <<EOF

9. ALERTES ET AVERTISSEMENTS
================================================================================
EOF

    grep -E '\[WARN\]|\[ERROR\]' "$LOG_FILE" 2>/dev/null | tail -30 | sed 's/^/  /' >> "$report_file"

    cat >> "$report_file" <<EOF

================================================================================
                        FIN DU RAPPORT
================================================================================
Généré le: $(date '+%Y-%m-%d %H:%M:%S')
================================================================================
EOF

    cat "$report_file"
}

################################################################################
# Main
################################################################################
main() {
    echo "📊 Génération du rapport quotidien..."
    echo ""

    generate_report

    # Optionnel: Envoyer par email
    if [[ -n "${ALERT_EMAIL:-}" ]] && command -v mail &>/dev/null; then
        local report_file="/tmp/daily-report-$(date +%Y%m%d).txt"
        mail -s "Daily Server Report - $(date +%Y-%m-%d)" "$ALERT_EMAIL" < "$report_file"
        echo ""
        echo "📧 Rapport envoyé par email à: $ALERT_EMAIL"
    fi
}

main "$@"
