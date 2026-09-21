# Automated Backup & Restore System

## 📋 Description

Build a production-ready automated backup system using Bash scripting that performs scheduled backups, manages retention policies, and enables quick restore operations. This project covers essential sysadmin skills for protecting data.

**Technologies**: Bash, Cron, Tar, Gzip, rsync (optional)

## 🎯 Objectives

- Create automated backup scripts with error handling
- Implement backup rotation and retention policies
- Set up cron scheduling for regular backups
- Build restore utilities for quick recovery
- Monitor backup status and disk usage
- Test backup integrity

## 📋 Prerequisites

- Linux system (Ubuntu/CentOS/Debian)
- Bash shell (4.0+)
- tar, gzip utilities
- cron daemon running
- Basic understanding of file permissions and cron syntax

## 🚀 Implementation Steps

### 1. Project Structure Setup
```bash
mkdir -p /opt/backups/scripts
mkdir -p /opt/backups/archives
mkdir -p /opt/backups/logs
```

### 2. Configure Backup Directories
- Edit `config.sh` to define source directories to backup
- Set backup destination and retention policy
- Configure notification email (optional)

### 3. Deploy Backup Script
- Place `backup.sh` in `/opt/backups/scripts/`
- Set execute permissions: `chmod +x backup.sh`
- Test script manually before scheduling

### 4. Create Cron Jobs
- Add daily backup job to crontab: `0 2 * * * /opt/backups/scripts/backup.sh`
- Add weekly full backup: `0 3 * * 0 /opt/backups/scripts/backup.sh full`
- Add rotation cleanup job: `0 4 * * * /opt/backups/scripts/cleanup.sh`

### 5. Build Restore Utilities
- Deploy `restore.sh` for quick restore operations
- Test restore procedure with sample files
- Document restore procedure

### 6. Monitoring & Testing
- Check backup logs regularly
- Verify backup file integrity: `tar -tzf backup.tar.gz > /dev/null`
- Test restore from backup monthly
- Monitor disk usage in backup destination

## 📚 What We Learn

✅ **Bash Scripting Best Practices**
- Error handling with trap, set -e, -u, -o pipefail
- Function definition and reusability
- Command-line argument parsing
- Logging and status reporting

✅ **Linux System Administration**
- Cron scheduling and timing
- File permissions and ownership
- Disk usage management (du, df)
- Backup rotation strategies (GFS: Grandfather-Father-Son)

✅ **Backup & Recovery Concepts**
- Full vs. incremental backups
- Backup retention policies
- Backup verification and testing
- Recovery Time Objective (RTO) & Recovery Point Objective (RPO)

✅ **Production-Ready Automation**
- Email notifications on failure
- Comprehensive logging
- Dry-run mode for testing
- Status monitoring and alerts

## 📂 Files Included

- `config.sh` - Configuration file with backup settings
- `backup.sh` - Main backup script with full/incremental logic
- `restore.sh` - Restore utility script
- `cleanup.sh` - Backup rotation and cleanup script
- `test-backup.sh` - Testing and validation script
- `backup.service` (optional) - Systemd timer alternative
- `backup.timer` (optional) - Systemd timer for scheduled backups

## 🧪 Testing

```bash
# Manual test backup
./backup.sh test

# Verify backup integrity
tar -tzf /opt/backups/archives/backup-*.tar.gz > /dev/null && echo "Backup OK"

# Test restore
./restore.sh --list /opt/backups/archives/latest.tar.gz
./restore.sh --extract /opt/backups/archives/latest.tar.gz /tmp/restore-test

# Check disk usage
du -sh /opt/backups/archives/*
```

## 🔒 Security Considerations

- Backups should be stored on separate disk/server
- Encrypt backups for sensitive data: `gpg --symmetric backup.tar.gz`
- Restrict backup directory permissions: `chmod 700 /opt/backups`
- Verify backup ownership: `chown root:root /opt/backups`
- Rotate encryption keys regularly
- Test restore from encrypted backups

## 📊 Expected Output

After running backups for a week, you should have:
- Daily incremental backups with rotating filenames
- Organized backup logs in `/opt/backups/logs/`
- Automated cleanup of old backups based on retention policy
- Email notifications on backup completion/failure
- Validated restore capability

## 🎓 Next Steps

1. Automate backup with cron
2. Set up off-site backup replication (rsync to remote server)
3. Implement encryption for sensitive data
4. Monitor backup metrics with Prometheus
5. Create disaster recovery runbook
6. Implement versioning with snapshots

## 📚 Resources

- Bash Scripting: https://mywiki.wooledge.org/BashGuide
- Cron Reference: https://crontab.guru/
- Backup Best Practices: https://www.digitalocean.com/community/tutorials/
- GNU tar Manual: https://www.gnu.org/software/tar/manual/
