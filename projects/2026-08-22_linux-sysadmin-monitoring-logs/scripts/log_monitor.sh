#!/bin/bash

################################################################################
# Log Monitor Script
# Surveille les fichiers de logs pour détecter les erreurs et avertissements
# Usage: ./log_monitor.sh [fichier_log] [pattern]
################################################################################

# Configuration
LOG_FILES=(
    "/var/log/syslog"
    "/var/log/auth.log"
    "/var/log/kernel.log"
    "/var/log/messages"
)

ALERT_PATTERNS=(
    "ERROR"
    "FAILED"
    "CRITICAL"
    "FATAL"
    "panic"
    "segfault"
    "out of memory"
)

MONITOR_LOG="/var/log/monitoring/log_monitor.log"
LAST_CHECK_FILE="/tmp/log_monitor_last_check"
ALERT_EMAIL="${ALERT_EMAIL:-admin@localhost}"

# Créer le dossier de logs
mkdir -p "$(dirname "$MONITOR_LOG")"

# Couleurs
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# ============================================================================
# FONCTIONS
# ============================================================================

log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$MONITOR_LOG"
}

send_alert() {
    local subject=$1
    local message=$2

    log_message "ALERT" "$subject"

    if command -v mail &> /dev/null; then
        echo -e "$message" | mail -s "$subject" "$ALERT_EMAIL" 2>/dev/null
    fi

    echo -e "${RED}⚠️  ALERTE: $subject${NC}"
}

# Initialiser le fichier de dernière vérification
init_last_check() {
    if [ ! -f "$LAST_CHECK_FILE" ]; then
        date '+%s' > "$LAST_CHECK_FILE"
    fi
}

# Obtenir le timestamp de la dernière vérification
get_last_check_time() {
    if [ -f "$LAST_CHECK_FILE" ]; then
        cat "$LAST_CHECK_FILE"
    else
        echo "0"
    fi
}

# Mettre à jour le timestamp
update_last_check() {
    date '+%s' > "$LAST_CHECK_FILE"
}

# Vérifier un fichier de logs
check_log_file() {
    local logfile=$1
    local errors_found=0
    local alert_message=""

    if [ ! -f "$logfile" ]; then
        return 0
    fi

    # Obtenir les modifications depuis la dernière vérification
    local last_check=$(get_last_check_time)
    local current_time=$(date '+%s')

    for pattern in "${ALERT_PATTERNS[@]}"; do
        # Chercher le pattern dans les dernières lignes du fichier
        local matches=$(grep -i "$pattern" "$logfile" 2>/dev/null | tail -100)
        local count=$(echo "$matches" | grep -i "$pattern" | wc -l)

        if [ "$count" -gt 0 ]; then
            echo -e "${RED}✗ $logfile: $count occurrence(s) de '$pattern'${NC}"

            # Afficher les dernières occurrences
            echo "$matches" | tail -3 | while read -r line; do
                echo "  > $line"
            done

            errors_found=$((errors_found + count))
            alert_message="${alert_message}Pattern '$pattern': $count occurrence(s)\n"
        fi
    done

    if [ "$errors_found" -gt 0 ]; then
        send_alert "Erreurs détectées dans $logfile ($errors_found)" \
            "Patterns détectés:\n$alert_message"
        return 1
    else
        echo -e "${GREEN}✓ $logfile: OK${NC}"
        return 0
    fi
}

# Vérifier la permission d'accès
check_permissions() {
    echo "Vérification des permissions de lecture..."
    for logfile in "${LOG_FILES[@]}"; do
        if [ -f "$logfile" ]; then
            if [ ! -r "$logfile" ]; then
                echo -e "${YELLOW}⚠️  Permission refusée: $logfile${NC}"
                echo "    (Lancez avec sudo si nécessaire)"
            fi
        fi
    done
}

# Obtenir les statistiques des fichiers de logs
get_log_stats() {
    echo ""
    echo "STATISTIQUES DES FICHIERS DE LOGS"
    echo "─────────────────────────────────────────────────────"
    printf "%-40s %10s %10s\n" "FICHIER" "TAILLE" "LIGNES"
    echo "─────────────────────────────────────────────────────"

    for logfile in "${LOG_FILES[@]}"; do
        if [ -f "$logfile" ]; then
            local size=$(du -h "$logfile" | cut -f1)
            local lines=$(wc -l < "$logfile")
            printf "%-40s %10s %10s\n" "$(basename "$logfile")" "$size" "$lines"
        fi
    done
}

# Afficher les patterns disponibles
show_patterns() {
    echo "Patterns surveillés:"
    printf '%s\n' "${ALERT_PATTERNS[@]}" | sed 's/^/  - /'
}

# Afficher les fichiers surveillés
show_files() {
    echo "Fichiers surveillés:"
    printf '%s\n' "${LOG_FILES[@]}" | sed 's/^/  - /'
}

# ============================================================================
# AFFICHAGE PRINCIPAL
# ============================================================================

main() {
    local exit_code=0

    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  LOG MONITOR - $(date '+%Y-%m-%d %H:%M')       ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""

    # Afficher la configuration
    show_files
    echo ""
    show_patterns
    echo ""

    # Vérifier les permissions
    check_permissions
    echo ""

    # Initialiser
    init_last_check

    # Vérifier chaque fichier
    for logfile in "${LOG_FILES[@]}"; do
        if [ -f "$logfile" ] && [ -r "$logfile" ]; then
            check_log_file "$logfile" || exit_code=1
        fi
    done

    # Afficher les statistiques
    get_log_stats

    # Mettre à jour le dernier check
    update_last_check

    echo ""
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""

    log_message "INFO" "Log monitor check completed"
    exit $exit_code
}

# ============================================================================
# EXÉCUTION
# ============================================================================

# Vérifier les arguments
if [ $# -gt 0 ]; then
    case "$1" in
        --list-files)
            show_files
            exit 0
            ;;
        --list-patterns)
            show_patterns
            exit 0
            ;;
        --check)
            main
            exit $?
            ;;
        *)
            echo "Usage: $0 [--list-files|--list-patterns|--check]"
            exit 1
            ;;
    esac
else
    main
fi
