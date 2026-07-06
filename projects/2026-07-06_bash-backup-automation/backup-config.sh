#!/bin/bash
###############################################################################
# Backup Configuration
# Centralize all backup settings here
###############################################################################

# Directories to backup
BACKUP_DIRS=(
    "/etc"
    "/home"
    "/opt"
    "/var/www"
)

# Exclude patterns (common patterns to exclude)
EXCLUDE_PATTERNS=(
    "*/node_modules"
    "*/venv"
    "*/\.git"
    "*/\.cache"
    "*/__pycache__"
    "*/tmp"
    "*/temp"
)

# Backup destination
BACKUP_BASE_DIR="/var/backups/custom-backups"
BACKUP_LOG_DIR="/var/log/backup"

# Backup naming convention
BACKUP_DATE=$(date +%Y-%m-%d_%H%M%S)
BACKUP_FILE="${BACKUP_BASE_DIR}/backup-${BACKUP_DATE}.tar.gz"
BACKUP_CHECKSUM="${BACKUP_FILE}.sha256"

# Retention policy
RETENTION_DAYS=7
MAX_BACKUPS=7

# Compression level (1-9, 9 = best compression but slower)
COMPRESSION_LEVEL=6

# Email configuration
SEND_EMAIL=true
EMAIL_TO="admin@example.com"
EMAIL_FROM="backup-system@$(hostname)"
SMTP_HOST="localhost"

# Logging
LOG_FILE="${BACKUP_LOG_DIR}/backup-$(date +%Y-%m).log"
VERBOSE=true

# Size thresholds for warnings (in MB)
WARN_SIZE_MB=1000
ERROR_SIZE_MB=5000

# Disk space warning threshold (in percentage)
WARN_DISK_PERCENT=80
ERROR_DISK_PERCENT=95

# Backup timeout (in seconds)
BACKUP_TIMEOUT=3600

# Parallel compression (number of cores to use, 0 = auto)
PARALLEL_JOBS=0
