#!/bin/bash
# Backup Configuration File

# Directories to backup (space-separated)
BACKUP_SOURCES=(
  "/home"
  "/etc"
  "/opt"
)

# Backup destination directory
BACKUP_DEST="/opt/backups/archives"

# Backup logs directory
LOGS_DIR="/opt/backups/logs"

# Backup retention policy (in days)
RETENTION_DAILY=7      # Keep daily backups for 7 days
RETENTION_WEEKLY=30    # Keep weekly backups for 30 days
RETENTION_MONTHLY=365  # Keep monthly backups for 1 year

# Backup schedule type (daily, weekly, monthly, full)
# Can be overridden via command line argument
BACKUP_TYPE="daily"

# Compression method (gzip, bzip2, xz)
COMPRESSION="gzip"

# Enable email notifications (true/false)
ENABLE_EMAIL_NOTIFICATIONS=true
EMAIL_RECIPIENT="admin@example.com"
EMAIL_ON_SUCCESS=false  # Only email on failure by default
EMAIL_ON_FAILURE=true

# Backup filename prefix
BACKUP_PREFIX="backup"

# Maximum backup file size before splitting (in MB, 0 = no limit)
MAX_BACKUP_SIZE=0

# Exclude patterns (space-separated, bash glob patterns)
EXCLUDE_PATTERNS=(
  "*.iso"
  "*.vmdk"
  "/tmp/*"
  "/var/tmp/*"
  "*.cache"
  "*/.git/*"
  "*/node_modules/*"
)

# Parallel compression jobs (for xz/pbzip2)
PARALLEL_JOBS=4

# Dry-run mode (test without actually creating backups)
DRY_RUN=false

# Enable compression (true/false)
ENABLE_COMPRESSION=true

# Verbose output (true/false)
VERBOSE=true

# Enable backup verification after completion
VERIFY_BACKUP=true

# Systemd timer service name
SYSTEMD_SERVICE_NAME="backup"
