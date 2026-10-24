.PHONY: help install-deps backup-full backup-incremental verify restore clean schedule-jobs

CONFIG := backup-config.conf
BACKUP_DEST := /mnt/backups
LOG_FILE := /var/log/backup-manager.log

help:
	@echo "Linux Backup & Recovery Automation"
	@echo "===================================="
	@echo ""
	@echo "Available targets:"
	@echo "  make install-deps      Install required dependencies"
	@echo "  make backup-full       Perform full backup"
	@echo "  make backup-incremental Perform incremental backup"
	@echo "  make verify            Verify backup integrity"
	@echo "  make restore           Restore from backup (interactive)"
	@echo "  make schedule-jobs     Setup cron jobs"
	@echo "  make schedule-remove   Remove cron jobs"
	@echo "  make logs              Show backup logs"
	@echo "  make clean             Clean up old backups"
	@echo "  make status            Show backup status"
	@echo ""
	@echo "Example:"
	@echo "  make backup-full"
	@echo "  make verify BACKUP_DEST=/mnt/backups"

install-deps:
	@echo "Checking dependencies..."
	@which bash tar gzip find md5sum > /dev/null && echo "✓ All dependencies found" || \
		(echo "✗ Missing dependencies"; exit 1)
	@chmod +x *.sh
	@echo "✓ Scripts are executable"

backup-full: install-deps
	@echo "Starting full backup..."
	@./backup-manager.sh --full --source-config $(CONFIG) --verbose

backup-incremental: install-deps
	@echo "Starting incremental backup..."
	@./backup-manager.sh --incremental --source-config $(CONFIG) --verbose

backup-dry-run: install-deps
	@echo "DRY RUN: Showing what would be backed up..."
	@./backup-manager.sh --full --source-config $(CONFIG) --dry-run

verify:
	@echo "Verifying backups in $(BACKUP_DEST)..."
	@./verify-backups.sh --backup-dir $(BACKUP_DEST) --verbose

verify-detailed:
	@echo "Detailed backup verification..."
	@./verify-backups.sh --backup-dir $(BACKUP_DEST) --detailed

restore:
	@echo "Interactive restore mode"
	@bash -c 'read -p "Enter backup file path: " backup; \
		./restore.sh --backup "$$backup" --list; \
		read -p "List contents? [y/n] " -n 1; \
		echo ""'

restore-file:
	@bash -c 'read -p "Enter backup file path: " backup; \
		read -p "Enter file path to restore: " file; \
		read -p "Enter destination directory [/tmp/restored]: " dest; \
		dest=$${dest:-/tmp/restored}; \
		./restore.sh --backup "$$backup" --restore --file "$$file" --dest "$$dest"'

restore-all:
	@bash -c 'read -p "Enter backup file path: " backup; \
		read -p "Enter destination directory [/tmp/restored]: " dest; \
		dest=$${dest:-/tmp/restored}; \
		./restore.sh --backup "$$backup" --restore --all --dest "$$dest"'

schedule-jobs: install-deps
	@echo "Setting up cron jobs..."
	@./cron-setup.sh --install --config $(CONFIG)

schedule-remove:
	@echo "Removing cron jobs..."
	@./cron-setup.sh --remove

schedule-status:
	@./cron-setup.sh --status

logs:
	@echo "Backup logs (last 50 lines):"
	@tail -50 $(LOG_FILE) 2>/dev/null || echo "Log file not found: $(LOG_FILE)"

logs-errors:
	@echo "Errors in backup logs:"
	@grep -i "error\|failed" $(LOG_FILE) 2>/dev/null || echo "No errors found"

clean:
	@read -p "Remove backups older than 30 days? [y/n] " -n 1; \
		if [ $$REPLY = "y" ]; then \
			find $(BACKUP_DEST) -maxdepth 1 -name "*-backup-*.tar*" -mtime +30 -delete; \
			echo "✓ Old backups removed"; \
		fi

status:
	@echo "Backup Status"
	@echo "=============="
	@echo "Backup destination: $(BACKUP_DEST)"
	@echo "Total backups: $$(find $(BACKUP_DEST) -maxdepth 1 -name '*-backup-*.tar*' -type f | wc -l)"
	@echo "Total size: $$(du -sh $(BACKUP_DEST) 2>/dev/null | cut -f1 || echo 'N/A')"
	@echo ""
	@echo "Recent backups:"
	@ls -lhS $(BACKUP_DEST)/*-backup-*.tar* 2>/dev/null | tail -5 | awk '{print "  " $$9 " (" $$5 ")"}'
	@echo ""
	@echo "Cron jobs:"
	@crontab -l 2>/dev/null | grep -c "backup-manager" && echo "  ✓ Cron jobs installed" || echo "  ✗ No cron jobs"

test-backup:
	@echo "Creating test backup..."
	@mkdir -p /tmp/test-backup-src
	@echo "test data" > /tmp/test-backup-src/test.txt
	@mkdir -p /tmp/test-backup-dest
	@tar -czf /tmp/test-backup-dest/test-backup.tar.gz -C /tmp test-backup-src/
	@echo "✓ Test backup created"
	@du -h /tmp/test-backup-dest/test-backup.tar.gz

test-restore:
	@echo "Testing restore from test backup..."
	@mkdir -p /tmp/test-restore
	@tar -xzf /tmp/test-backup-dest/test-backup.tar.gz -C /tmp/test-restore/
	@echo "✓ Test restore completed"
	@echo "Restored files:"
	@find /tmp/test-restore -type f

test-all: test-backup test-restore
	@echo "✓ All tests passed"

cleanup-test:
	@rm -rf /tmp/test-backup-src /tmp/test-backup-dest /tmp/test-restore
	@echo "✓ Test files cleaned up"
