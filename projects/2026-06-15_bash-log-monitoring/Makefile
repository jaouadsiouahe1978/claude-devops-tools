.PHONY: help test install start stop status logs analyze rotate report clean

PROJECT_DIR := $(shell pwd)
SCRIPTS_DIR := $(PROJECT_DIR)/scripts
CONFIG_FILE := $(PROJECT_DIR)/config/monitoring.conf

help:
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "  Log Monitoring System - Available Commands"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "Setup:"
	@echo "  make install     - Install cron jobs"
	@echo "  make test        - Run test suite"
	@echo ""
	@echo "Operations:"
	@echo "  make start       - Start monitoring"
	@echo "  make stop        - Stop monitoring"
	@echo "  make status      - Check monitor status"
	@echo ""
	@echo "Analysis:"
	@echo "  make analyze     - Analyze logs"
	@echo "  make report      - Generate report"
	@echo ""
	@echo "Maintenance:"
	@echo "  make rotate      - Rotate log files"
	@echo "  make logs        - View alerts log"
	@echo "  make clean       - Clean generated files"
	@echo ""

test:
	@echo "Running tests..."
	@bash $(PROJECT_DIR)/tests/test-runner.sh

install:
	@echo "Installing cron jobs..."
	@bash $(SCRIPTS_DIR)/../cron/cron-jobs.sh --install

start:
	@echo "Starting log monitor..."
	@bash $(SCRIPTS_DIR)/log-monitor.sh

stop:
	@echo "Stopping log monitor..."
	@bash $(SCRIPTS_DIR)/log-monitor.sh --stop

status:
	@bash $(SCRIPTS_DIR)/log-monitor.sh --status

logs:
	@echo "Recent alerts:"
	@tail -20 data/alerts.log 2>/dev/null || echo "No alerts yet"

analyze:
	@bash $(SCRIPTS_DIR)/log-analyzer.sh /var/log/syslog

report:
	@echo "Generating report..."
	@bash $(SCRIPTS_DIR)/report-generator.sh $(shell date '+%Y-%m-%d') all

rotate:
	@echo "Rotating logs..."
	@bash $(SCRIPTS_DIR)/log-rotator.sh --full

clean:
	@echo "Cleaning..."
	@rm -rf data/*.log
	@rm -rf data/reports/*
	@echo "✓ Clean complete"

.DEFAULT_GOAL := help
