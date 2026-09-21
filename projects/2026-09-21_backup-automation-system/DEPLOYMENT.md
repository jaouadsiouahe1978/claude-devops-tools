# Backup System Deployment Guide

## Quick Start (5 minutes)

### 1. Setup Directory Structure
```bash
sudo mkdir -p /opt/backups/{scripts,archives,logs}
sudo chown root:root /opt/backups
sudo chmod 700 /opt/backups
```

### 2. Copy Scripts
```bash
sudo cp backup.sh restore.sh cleanup.sh /opt/backups/scripts/
sudo chmod 755 /opt/backups/scripts/*.sh
```

### 3. Copy Configuration
```bash
sudo cp config.sh /opt/backups/scripts/
sudo chmod 644 /opt/backups/scripts/config.sh
```

### 4. Edit Configuration
```bash
sudo nano /opt/backups/scripts/config.sh

# Required changes:
# - Update BACKUP_SOURCES array
# - Set EMAIL_RECIPIENT for notifications
# - Adjust retention policies
```

### 5. Test the Backup
```bash
sudo /opt/backups/scripts/backup.sh daily
```

### 6. Verify Backup
```bash
ls -lh /opt/backups/archives/
tar -tzf /opt/backups/archives/backup-daily-*.tar.gz | head -20
```

## Scheduling with Cron

### Edit Crontab
```bash
sudo crontab -e
```

### Add Cron Jobs
```bash
# Daily backup at 2 AM
0 2 * * * /opt/backups/scripts/backup.sh daily

# Weekly full backup (Sunday at 3 AM)
0 3 * * 0 /opt/backups/scripts/backup.sh weekly

# Monthly backup (1st of month at 4 AM)
0 4 1 * * /opt/backups/scripts/backup.sh monthly

# Daily cleanup at 5 AM
0 5 * * * /opt/backups/scripts/cleanup.sh retention

# Weekly integrity check (Sunday at 6 AM)
0 6 * * 0 /opt/backups/scripts/cleanup.sh verify
```

## Scheduling with Systemd Timers

### Enable Timers
```bash
# Reload systemd configuration
sudo systemctl daemon-reload

# Enable timer
sudo systemctl enable backup.timer

# Start timer
sudo systemctl start backup.timer

# Check status
sudo systemctl status backup.timer
```

## Restore Procedures

### List Available Backups
```bash
/opt/backups/scripts/restore.sh --list-backups
```

### Verify Backup Integrity
```bash
/opt/backups/scripts/restore.sh --verify /opt/backups/archives/backup-*.tar.gz
```

### Extract Entire Backup
```bash
/opt/backups/scripts/restore.sh --extract \
  /opt/backups/archives/backup-daily-2026-09-21-02-00-00.tar.gz \
  /tmp/restore
```

### Extract Single File
```bash
/opt/backups/scripts/restore.sh --extract-single \
  /opt/backups/archives/backup-daily-2026-09-21-02-00-00.tar.gz \
  /etc/passwd \
  /tmp/restore/
```

## Monitoring & Maintenance

### Check Backup Status
```bash
ls -lh /opt/backups/archives/ | tail -5
du -sh /opt/backups/archives/
df -h /opt/backups/
```

### View Logs
```bash
sudo tail -50 /opt/backups/logs/backup-$(date +%Y-%m-%d).log
```

### Clean Old Backups
```bash
sudo /opt/backups/scripts/cleanup.sh retention
sudo /opt/backups/scripts/cleanup.sh verify
```

## Security Best Practices

### 1. Encrypt Backups
```bash
gpg --symmetric /opt/backups/archives/backup-*.tar.gz
```

### 2. Off-site Backup
```bash
rsync -av --delete /opt/backups/archives/ \
  remote-user@backup-server:/backups/
```

### 3. File Permissions
```bash
sudo chmod 700 /opt/backups
sudo chmod 700 /opt/backups/archives
sudo chmod 700 /opt/backups/logs
```

## Troubleshooting

### Check if service/timer is active
```bash
sudo systemctl status backup.timer
sudo journalctl -u backup -n 50
```

### Manual backup run
```bash
sudo /opt/backups/scripts/backup.sh daily -v
```

### Disk space issues
```bash
df -h /opt/backups
sudo /opt/backups/scripts/cleanup.sh retention
```

For more information, see README.md
