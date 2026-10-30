# Installation Guide - Log Monitor System

## Quick Install

```bash
# Clone to your system
cd bash-log-monitor

# Run installer with sudo
sudo ./bin/install.sh

# Edit configuration
sudo nano /opt/log-monitor/config/log-monitor.conf

# Verify installation
sudo /opt/log-monitor/bin/log-monitor.sh --config /opt/log-monitor/config/log-monitor.conf

# Enable monitoring
sudo systemctl enable --now log-monitor.timer
```

## Detailed Installation

### Step 1: System Requirements

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install -y \
    mailutils \
    grep \
    sed \
    gawk \
    curl
```

**CentOS/RHEL:**
```bash
sudo yum install -y \
    mailx \
    grep \
    sed \
    gawk \
    curl
```

**Verify mail functionality:**
```bash
# Check if postfix/sendmail is running
sudo systemctl status postfix
# OR
sudo systemctl status sendmail

# If not installed, install postfix:
# Debian: sudo apt-get install -y postfix
# CentOS: sudo yum install -y postfix
```

### Step 2: Download and Extract

```bash
# Option A: From repository
git clone https://github.com/yourusername/claude-devops-tools.git
cd claude-devops-tools/projects/2026-10-30_bash-log-monitor

# Option B: Download as archive
wget https://example.com/bash-log-monitor.tar.gz
tar -xzf bash-log-monitor.tar.gz
cd bash-log-monitor
```

### Step 3: Run Installation Script

```bash
# Make installer executable (if needed)
chmod +x bin/install.sh

# Run as root
sudo ./bin/install.sh

# Expected output:
# ✓ All prerequisites met
# ✓ Directories created at /opt/log-monitor
# ✓ Installed bin/log-monitor.sh
# ✓ Installed config/log-monitor.conf
# ✓ Installed config/alert-rules.conf
# ✓ Systemd timer created
# ✓ Cron job installed
# ✓ Installation verified successfully
```

### Step 4: Configuration

**Edit main configuration:**
```bash
sudo nano /opt/log-monitor/config/log-monitor.conf
```

Key settings to configure:

```bash
# Which logs to monitor
LOGS_TO_MONITOR="/var/log/syslog /var/log/auth.log /var/log/nginx/error.log"

# Alert email address
ALERT_EMAIL="admin@example.com"

# Alert storage directory
ALERT_DIR="/var/log/log-monitor"

# Enable/disable features
ENABLE_EMAIL_ALERTS=true
ENABLE_FILE_ARCHIVE=true

# Optional: Slack/Discord webhooks
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
```

**Configure alert rules:**
```bash
sudo nano /opt/log-monitor/config/alert-rules.conf
```

Add patterns that should trigger alerts (one per line):

```
ERROR
CRITICAL
Failed password
Out of memory
Connection refused
Segmentation fault
Permission denied
```

### Step 5: Testing

**Test with dry-run mode (no real emails sent):**
```bash
DRY_RUN=true sudo /opt/log-monitor/bin/log-monitor.sh \
    --config /opt/log-monitor/config/log-monitor.conf
```

**Run test suite:**
```bash
cd bash-log-monitor
chmod +x tests/test-alert.sh
./tests/test-alert.sh
```

**Send test email:**
```bash
echo "Test email from Log Monitor" | \
    mail -s "Log Monitor Test" admin@example.com

# Check mail logs
tail -f /var/log/mail.log  # Debian/Ubuntu
tail -f /var/log/maillog   # CentOS/RHEL
```

### Step 6: Enable Monitoring

**Option A: Using Systemd Timer (Recommended)**

```bash
# Enable and start the timer
sudo systemctl enable --now log-monitor.timer

# Check status
sudo systemctl status log-monitor.timer

# View timer logs
sudo journalctl -u log-monitor.service -f

# Test timer manually
sudo systemctl start log-monitor.service
```

**Option B: Using Cron**

The installer automatically adds a cron job. View it with:

```bash
crontab -l

# Expected output:
# */5 * * * * /opt/log-monitor/bin/log-monitor.sh --config \
#   /opt/log-monitor/config/log-monitor.conf >> \
#   /opt/log-monitor/alerts/log-monitor.log 2>&1
```

To customize the schedule:

```bash
# Edit cron jobs
crontab -e

# Examples:
# Every 5 minutes:     */5 * * * *
# Every hour:          0 * * * *
# Every 6 hours:       0 */6 * * *
# At 3 AM daily:       0 3 * * *
# Every 15 minutes:    */15 * * * *
```

### Step 7: Verification

**Check installation:**
```bash
# List installed files
ls -la /opt/log-monitor/

# Run monitor once
sudo /opt/log-monitor/bin/log-monitor.sh --config /opt/log-monitor/config/log-monitor.conf

# View logs
tail -f /opt/log-monitor/alerts/log-monitor.log

# Check alerts
ls -la /opt/log-monitor/alerts/
```

**Monitor system health:**
```bash
# Check timer status
sudo systemctl list-timers log-monitor.timer

# View recent executions
sudo journalctl -u log-monitor.service -n 50

# Check for errors
sudo journalctl -u log-monitor.service | grep ERROR
```

## Troubleshooting

### Email alerts not working

```bash
# Check postfix status
sudo systemctl status postfix

# Test mail delivery
echo "Test" | mail -s "Test Mail" your-email@example.com

# View mail logs
sudo tail -f /var/log/mail.log

# Check mail queue
sudo mailq
sudo postqueue -p
```

### Monitor not running

```bash
# Check timer
sudo systemctl status log-monitor.timer

# Manual run with debug
sudo /opt/log-monitor/bin/log-monitor.sh --config /opt/log-monitor/config/log-monitor.conf

# View recent runs
sudo journalctl -u log-monitor.service -n 20
```

### Permissions issues

```bash
# Fix directory permissions
sudo chown -R root:root /opt/log-monitor
sudo chmod 755 /opt/log-monitor
sudo chmod 755 /opt/log-monitor/bin
sudo chmod 755 /opt/log-monitor/alerts
sudo chmod 644 /opt/log-monitor/config/*
```

### Log files not found

```bash
# Verify log files exist and are readable
ls -la /var/log/syslog
ls -la /var/log/auth.log
ls -la /var/log/nginx/error.log

# Check permissions
sudo cat /var/log/auth.log | head

# Adjust monitoring user if needed
# Add to sudoers or update group membership
```

## Uninstallation

```bash
# Disable and remove timer
sudo systemctl disable log-monitor.timer
sudo systemctl disable log-monitor.service
sudo rm /etc/systemd/system/log-monitor.*

# Remove cron job
crontab -e  # Manually remove the log-monitor line

# Remove installation directory
sudo rm -rf /opt/log-monitor

# Remove from sudo (if configured)
sudo visudo  # Remove any log-monitor entries

# Reload systemd
sudo systemctl daemon-reload
```

## Advanced Configuration

### Monitor multiple servers

Create a wrapper script:

```bash
#!/bin/bash
for server in web1 web2 db1 db2; do
    ssh "$server" '/opt/log-monitor/bin/log-monitor.sh \
        --config /opt/log-monitor/config/log-monitor.conf'
done
```

### Send alerts to multiple channels

Edit `/opt/log-monitor/bin/log-monitor.sh` to add webhook support:

```bash
# Add Slack notification function
send_slack_alert() {
    local msg="$1"
    curl -X POST "$SLACK_WEBHOOK_URL" \
        -H 'Content-Type: application/json' \
        -d "{\"text\": \"$msg\"}"
}
```

### Archive alerts long-term

```bash
# Add to cron for weekly compression
0 0 * * 0 gzip /opt/log-monitor/alerts/*.alert
```

### Monitor remote logs

```bash
# Add rsyslog forwarding configuration
# /etc/rsyslog.d/forward.conf
*.* @@remote.syslog.server:514
```

## Performance Optimization

### For large log files

```bash
# Modify log-monitor.sh to use tail instead of full read
tail -n 1000 "$log_file" | grep -E "$rule"
```

### For high-volume servers

```bash
# Increase check interval in config
CHECK_INTERVAL=30  # Every 30 minutes instead of 5

# Or adjust cron schedule
# Run every 15 minutes instead of 5
*/15 * * * * /opt/log-monitor/bin/log-monitor.sh
```

### Archive old alerts

```bash
# Add to cron for cleanup
# Keep only 30 days of alerts
find /opt/log-monitor/alerts -name "*.alert" -mtime +30 -delete
```

## Support and Documentation

- **README.md** - Full feature documentation
- **config/log-monitor.conf** - Configuration options
- **config/alert-rules.conf** - Alert patterns
- **tests/test-alert.sh** - Test suite

## Next Steps

1. Customize alert rules for your environment
2. Configure email recipients
3. Set up monitoring schedule
4. Test with sample logs
5. Deploy to production servers
6. Set up log rotation for alerts
7. Create dashboard to track alerts

---

**Created:** 2026-10-30  
**For:** DevOps/SRE Training - Grenoble  
**Status:** Production Ready
