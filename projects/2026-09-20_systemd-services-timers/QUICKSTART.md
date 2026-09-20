# Quick Start - Systemd Services & Timer Units

## Fast Setup (5 minutes)

```bash
# 1. Make scripts executable
chmod +x backup.sh health-check.sh setup.sh

# 2. Run setup as root
sudo ./setup.sh

# 3. Start the timer
sudo systemctl start backup.timer

# 4. Verify it's running
systemctl list-timers backup.timer
```

## Common Operations

### View Timer Status
```bash
# List all timers
systemctl list-timers --all

# Show specific timer details
sudo systemctl status backup.timer

# Show next run time
sudo systemctl list-timers backup.timer
```

### Run Backup Manually
```bash
# Execute backup service immediately
sudo systemctl start backup.service

# Watch it running
sudo systemctl status backup.service

# View live logs
sudo journalctl -u backup.service -f
```

### Check Logs
```bash
# Last 20 backup logs
sudo journalctl -u backup.service -n 20

# Follow logs in real-time
sudo journalctl -u backup.service -f

# Logs from last 6 hours
sudo journalctl -u backup.service --since "6h ago"

# Show all journal entries
sudo journalctl -u backup.service | less
```

### Enable/Disable at Boot
```bash
# Enable: timer starts automatically on boot
sudo systemctl enable backup.timer

# Disable: timer won't start on boot
sudo systemctl disable backup.timer

# Check if enabled
systemctl is-enabled backup.timer
```

### View Backups
```bash
# List all backups
ls -lh /opt/backups/data_*.tar.gz

# Show disk space used
du -sh /opt/backups/

# Check backup integrity
tar -tzf /opt/backups/data_*.tar.gz | head -20
```

## Modify Timer Schedule

Edit `/etc/systemd/system/backup.timer`:

```bash
# Open in editor
sudo nano /etc/systemd/system/backup.timer
```

Common schedule examples:

```ini
# Every day at 2 AM
OnCalendar=*-*-* 02:00:00

# Every 6 hours
OnCalendar=*-*-* 00,06,12,18:00:00

# Weekdays at 9 AM
OnCalendar=Mon..Fri *-*-* 09:00:00

# Every Sunday at 3 AM
OnCalendar=Sun *-*-* 03:00:00

# Every 15 minutes
OnBootSec=15min
OnUnitActiveSec=15min
```

After editing:
```bash
sudo systemctl daemon-reload
sudo systemctl restart backup.timer
```

## Troubleshooting

### Timer not running?
```bash
# Check if timer exists and is enabled
sudo systemctl list-timers backup.timer

# Check service file syntax
sudo systemd-analyze verify backup.service

# Check timer file syntax
sudo systemd-analyze verify backup.timer
```

### Permission denied errors?
```bash
# Check ownership
ls -la /opt/backups/
ls -la /opt/backups/backup.sh

# Fix permissions (if needed)
sudo chown backupuser:backupuser /opt/backups/*
sudo chmod 755 /opt/backups/*.sh
```

### Backup not being created?
```bash
# Run manually with debug
sudo systemctl start backup.service

# Check logs immediately
sudo journalctl -u backup.service -n 30

# Check if backup directory exists
ls -la /opt/backups/
```

### Timer runs but service fails?
```bash
# Check service logs
sudo journalctl -u backup.service -n 50

# Check service status
sudo systemctl status backup.service

# Verify script permissions
sudo -u backupuser /opt/backups/backup.sh
```

## Health Check

Run the health check script:
```bash
# Manual health check
sudo /opt/backups/health-check.sh

# See health check logs
tail -f /opt/backups/health-check.log
```

## Clean Up

To remove this service:
```bash
# Stop timer and service
sudo systemctl stop backup.timer
sudo systemctl stop backup.service

# Disable at boot
sudo systemctl disable backup.timer

# Remove service files
sudo rm /etc/systemd/system/backup.*
sudo rm /etc/systemd/system/app-dependent.service

# Reload systemd
sudo systemctl daemon-reload

# Optional: remove user and files
sudo userdel backupuser
sudo rm -rf /opt/backups
```

## Testing the Timer

To test with frequent executions:

```bash
# Edit timer
sudo nano /etc/systemd/system/backup.timer

# Change to:
# OnBootSec=10s
# OnUnitActiveSec=2min

# Apply changes
sudo systemctl daemon-reload
sudo systemctl restart backup.timer

# Watch it execute
sudo journalctl -u backup.service -f
```

## Learn More

- Man pages: `man systemd.service`, `man systemd.timer`
- Systemd docs: https://www.freedesktop.org/wiki/Software/systemd/
- Timer examples: https://www.freedesktop.org/software/systemd/man/systemd.timer.html
