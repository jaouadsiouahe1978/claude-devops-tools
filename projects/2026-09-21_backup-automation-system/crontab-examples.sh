#!/bin/bash
# Crontab Examples
# Add these lines to your crontab (crontab -e) to schedule automated backups

# Format: minute hour day month day-of-week command

# Daily backup at 2:00 AM
0 2 * * * /opt/backups/scripts/backup.sh daily

# Weekly full backup every Sunday at 3:00 AM
0 3 * * 0 /opt/backups/scripts/backup.sh weekly

# Monthly backup on the 1st day of month at 4:00 AM
0 4 1 * * /opt/backups/scripts/backup.sh monthly

# Cleanup old backups daily at 5:00 AM
0 5 * * * /opt/backups/scripts/cleanup.sh retention

# Verify all backups every Sunday at 6:00 AM
0 6 * * 0 /opt/backups/scripts/cleanup.sh verify
