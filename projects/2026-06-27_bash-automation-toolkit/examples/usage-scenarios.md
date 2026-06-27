# Real-World DevOps Scenarios

## Scenario 1: SaaS Application Deployment & Monitoring

**Setup**: You have a web app running on a single server that needs:
- Daily database backups
- Real-time system monitoring
- Automated deployments from Git
- Log rotation to prevent disk overflow

**Daily Routine**:

```bash
# Morning: Deploy latest code (2 AM)
0 2 * * * /home/user/scripts/app-deployment.sh \
  --repo https://github.com/mycompany/webapp.git \
  --branch main \
  --target /opt/webapp \
  --healthcheck http://localhost:3000/health \
  --build "npm run build"

# Backup database after deployment (2:30 AM)
30 2 * * * /home/user/scripts/backup-databases.sh \
  --type postgres \
  --output /backups \
  --retention 30

# Monitor every 5 minutes
*/5 * * * * /home/user/scripts/system-health-check.sh \
  --cpu-alert 80 --mem-alert 85

# Clean old logs daily (3 AM)
0 3 * * * /home/user/scripts/log-rotation-manager.sh \
  --dir /var/log/webapp \
  --size 50M \
  --keep 14
```

**Response to alert** (high memory):
```bash
# Trigger cleanup if needed
if /home/user/scripts/system-health-check.sh 2>&1 | grep -q "Memory.*CRITICAL"; then
  /home/user/scripts/cleanup-old-files.sh \
    --days 7 \
    --min-size 5M \
    --force /tmp /var/cache
fi
```

---

## Scenario 2: Multi-Database Backup Strategy

**Setup**: You manage multiple databases:
- PostgreSQL (main application)
- MySQL (legacy system)
- SQLite (local cache)

**Backup strategy** (daily + weekly rotation):

```bash
# PostgreSQL - every night at 2 AM (30-day retention)
0 2 * * * /home/user/scripts/backup-databases.sh \
  --type postgres \
  --output /backups/postgres \
  --retention 30

# MySQL - every night at 2:15 AM (14-day retention)
15 2 * * * /home/user/scripts/backup-databases.sh \
  --type mysql \
  --db-user backupuser \
  --output /backups/mysql \
  --retention 14

# Weekly full backup to external drive (Sunday 3 AM)
0 3 * * 0 \
  tar -czf /mnt/backup-drive/full-backup-$(date +%Y%m%d).tar.gz \
    /backups/postgres /backups/mysql && \
  echo "Full backup completed" | mail -s "Weekly Backup" admin@example.com
```

**Verification script** (test backups weekly):
```bash
#!/bin/bash
# Verify backups are valid
for backup in /backups/postgres/*.gz; do
  if ! gunzip -t "$backup" 2>/dev/null; then
    echo "CORRUPT BACKUP: $backup" | mail -s "Backup Failed" admin@example.com
  fi
done
```

---

## Scenario 3: High-Traffic Web Server

**Setup**: High-traffic server that generates lots of logs and needs aggressive monitoring.

```bash
# Monitor every 1 minute (catch issues fast)
* * * * * /home/user/scripts/system-health-check.sh \
  --cpu-alert 70 --mem-alert 75 --disk-alert 85

# Rotate NGINX logs before they get huge
0 * * * * /home/user/scripts/log-rotation-manager.sh \
  --dir /var/log/nginx \
  --size 50M \
  --keep 7 \
  --compress

# Clean temp files every 2 hours
0 */2 * * * /home/user/scripts/cleanup-old-files.sh \
  --days 1 \
  --force /tmp /var/tmp /var/cache

# Hourly report if any threshold breached
0 * * * * /home/user/scripts/system-health-check.sh | \
  grep -E "WARNING|CRITICAL" | \
  mail -s "Health Alert" ops@example.com || true
```

**Emergency response** (if disk critical):
```bash
# Run in advance of automatic cleanup
if [ $(df / | awk 'NR==2 {print $5}' | cut -d% -f1) -gt 85 ]; then
  # Clean logs aggressively
  /home/user/scripts/log-rotation-manager.sh \
    --dir /var/log \
    --size 20M \
    --keep 3

  # Clean cache
  /home/user/scripts/cleanup-old-files.sh \
    --days 1 --force /var/cache /tmp

  # Alert
  echo "Disk space critical! Cleaned old files." | \
    mail -s "Disk Emergency" ops@example.com
fi
```

---

## Scenario 4: Development Server with CI/CD

**Setup**: Server that receives deployments from GitHub Actions.

```bash
# Deploy on push to main (webhook trigger - manual call)
# This would be called by your CI/CD pipeline:
/home/user/scripts/app-deployment.sh \
  --repo https://github.com/user/project.git \
  --branch main \
  --target /var/www/app \
  --healthcheck http://localhost:3000/api/health \
  --build "npm install && npm run build"

# Quick health check after deploy
/home/user/scripts/system-health-check.sh --no-color

# Backup development database daily (2 AM)
0 2 * * * /home/user/scripts/backup-databases.sh \
  --type postgres \
  --db-name dev_app \
  --output /backups \
  --retention 7
```

**Rollback script** (if health check fails):
```bash
#!/bin/bash
# Automatic rollback if deployment fails health check

REPO="/var/www/app"
BACKUP="${REPO}.backup.$(ls -t ${REPO}.backup.* 2>/dev/null | head -1 | xargs -I {} basename {})"

if ! curl -sf http://localhost:3000/api/health >/dev/null; then
  echo "Health check failed! Rolling back..."
  rm -rf "$REPO"
  mv "$BACKUP" "$REPO"
  systemctl restart app
  echo "Rolled back to previous version"
fi
```

---

## Scenario 5: Database Server with Replication

**Setup**: Primary database server with automated backups for PITR (Point-in-Time Recovery).

```bash
# Hourly WAL (Write-Ahead Log) archiving
0 * * * * /home/user/scripts/backup-databases.sh \
  --type postgres \
  --output /wal-archive \
  --retention 7

# Daily base backup (full database snapshot)
0 2 * * * /home/user/scripts/backup-databases.sh \
  --type postgres \
  --output /backups \
  --retention 30

# Clean old WALs every 12 hours
0 */12 * * * /home/user/scripts/cleanup-old-files.sh \
  --days 7 \
  --min-size 100M \
  /wal-archive
```

---

## Scenario 6: Microservices on Single Server

**Setup**: Multiple services running, each with their own logs and configs.

```bash
# Service 1: API server
0 2 * * * /home/user/scripts/backup-databases.sh \
  --type postgres \
  --db-name api_prod \
  --output /backups/api \
  --retention 30

# Service 2: Message queue
0 2 * * * /home/user/scripts/backup-databases.sh \
  --type postgres \
  --db-name queue_prod \
  --output /backups/queue \
  --retention 7

# Service 3: Cache
0 * * * * /home/user/scripts/cleanup-old-files.sh \
  --days 1 \
  --force /var/cache/service3

# Monitor all services
*/5 * * * * /home/user/scripts/system-health-check.sh >> /var/log/health.log

# Rotate logs for each service
0 */4 * * * for dir in /var/log/api /var/log/queue /var/log/cache; do \
  /home/user/scripts/log-rotation-manager.sh --dir "$dir" --size 100M --keep 14; \
done
```

---

## Scenario 7: On-Premises vs Cloud Hybrid

**Setup**: Running on-prem servers but backing up to cloud storage.

```bash
# Local backup (fast, immediate recovery)
0 2 * * * /home/user/scripts/backup-databases.sh \
  --type postgres \
  --output /local-backups \
  --retention 7

# Cloud backup (offsite, long-term)
30 2 * * * tar -czf - /local-backups | \
  aws s3 cp - s3://my-backup-bucket/db-$(date +%Y%m%d).tar.gz

# Verify cloud backup exists
0 3 * * * aws s3 ls s3://my-backup-bucket/ | grep -q "$(date +%Y%m%d)" || \
  echo "Cloud backup missing!" | mail -s "Alert" admin@example.com
```

---

## Tips & Tricks

### 1. **Dry-Run Before Running**

Always test with `--dry-run` first:

```bash
./backup-databases.sh --type postgres --output /backups --dry-run
./log-rotation-manager.sh --dir /var/log --dry-run
./cleanup-old-files.sh --days 30 /tmp --dry-run
```

### 2. **Parallel Execution**

Run multiple scripts in parallel for speed:

```bash
(
  /home/user/scripts/backup-databases.sh --type postgres &
  /home/user/scripts/backup-databases.sh --type mysql &
  wait
) && echo "All backups done"
```

### 3. **Error Handling in Cron**

Capture errors and notify:

```bash
0 2 * * * {
  if /home/user/scripts/backup-databases.sh --type postgres; then
    echo "✅ Backup successful" | mail -s "Backup OK" admin@example.com
  else
    echo "❌ Backup failed!" | mail -s "Backup Failed" admin@example.com
  fi
}
```

### 4. **Monitor the Scripts Themselves**

Make sure cron jobs are actually running:

```bash
# Check if backup ran today
0 10 * * * test -f /backups/postgres_*.gz -newermt "$(date -d '8 hours ago')" || \
  echo "Backup did not run!" | mail -s "Alert" admin@example.com
```

### 5. **Use Log Files**

Direct output to files for debugging:

```bash
LOGDIR="/var/log/devops-scripts"
mkdir -p "$LOGDIR"

0 2 * * * /home/user/scripts/backup-databases.sh \
  --type postgres >> "$LOGDIR/backup.log" 2>&1
```

Then tail the logs:
```bash
tail -f /var/log/devops-scripts/backup.log
```

### 6. **Systemd Service Alternative**

Instead of cron, create a systemd service:

```ini
# /etc/systemd/system/backup.service
[Unit]
Description=Database Backup
After=network.target

[Service]
Type=oneshot
ExecStart=/home/user/scripts/backup-databases.sh --type postgres --output /backups
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

```ini
# /etc/systemd/system/backup.timer
[Unit]
Description=Daily Database Backup

[Timer]
OnCalendar=*-*-* 02:00:00
Persistent=true

[Install]
WantedBy=timers.target
```

Then:
```bash
systemctl enable backup.timer
systemctl start backup.timer
systemctl status backup.timer
```

Monitor:
```bash
journalctl -u backup.service -f
```

---

## Summary

These scripts are flexible and can be combined for almost any DevOps scenario:

| Scenario | Key Scripts | Frequency |
|----------|------------|-----------|
| Simple LAMP stack | backup-databases + system-health-check | Daily |
| High-traffic server | log-rotation + system-health-check + cleanup | Hourly-Daily |
| Multi-database | backup-databases (multiple calls) | Daily |
| CI/CD pipeline | app-deployment | On-trigger |
| Database server | backup-databases + cleanup | Multiple daily |

The key is combining them into a routine that matches your infrastructure and SLA requirements!
