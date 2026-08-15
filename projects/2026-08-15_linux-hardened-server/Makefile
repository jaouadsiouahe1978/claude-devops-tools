.PHONY: help setup all verify clean 01-initial 02-users 03-ssh 04-firewall 05-fail2ban 06-audit 07-checklist

BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m

help:
	@echo "$(BLUE)=== Linux Hardened Server Setup ===$(NC)"
	@echo ""
	@echo "$(GREEN)Available targets:$(NC)"
	@echo "  $(YELLOW)setup/all$(NC)      - Run all hardening steps"
	@echo "  $(YELLOW)verify$(NC)        - Run security checklist"
	@echo "  $(YELLOW)01-initial$(NC)    - Initial system setup"
	@echo "  $(YELLOW)02-users$(NC)      - User management"
	@echo "  $(YELLOW)03-ssh$(NC)        - SSH hardening"
	@echo "  $(YELLOW)04-firewall$(NC)   - Firewall setup (UFW)"
	@echo "  $(YELLOW)05-fail2ban$(NC)   - Fail2ban setup"
	@echo "  $(YELLOW)06-audit$(NC)      - Audit daemon setup"
	@echo "  $(YELLOW)07-checklist$(NC)  - Security verification"
	@echo ""
	@echo "$(GREEN)Usage:$(NC)"
	@echo "  $(YELLOW)sudo make setup$(NC)   # Run all hardening"
	@echo "  $(YELLOW)sudo make verify$(NC)  # Check security posture"

01-initial:
	@chmod +x scripts/01_initial_setup.sh && sudo scripts/01_initial_setup.sh

02-users:
	@chmod +x scripts/02_users_setup.sh && sudo scripts/02_users_setup.sh

03-ssh:
	@chmod +x scripts/03_ssh_hardening.sh && sudo scripts/03_ssh_hardening.sh

04-firewall:
	@chmod +x scripts/04_firewall_setup.sh && sudo scripts/04_firewall_setup.sh

05-fail2ban:
	@chmod +x scripts/05_fail2ban_setup.sh && sudo scripts/05_fail2ban_setup.sh

06-audit:
	@chmod +x scripts/06_audit_setup.sh && sudo scripts/06_audit_setup.sh

07-checklist:
	@chmod +x scripts/07_security_checklist.sh && sudo scripts/07_security_checklist.sh

setup: 01-initial 02-users 03-ssh 04-firewall 05-fail2ban 06-audit
	@echo ""
	@echo "$(GREEN)✓ All setup steps completed!$(NC)"

all: setup

verify: 07-checklist

clean:
	@echo "$(YELLOW)Cleaning...$(NC)"
	@rm -f /tmp/hardened-* 2>/dev/null || true

.DEFAULT_GOAL := help
