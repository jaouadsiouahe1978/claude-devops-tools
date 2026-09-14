# 🚀 Quick Start Guide - Linux Firewall Security Lab

## 5 Minutes Setup

### Option 1: Run on your local machine (Ubuntu/Debian)

```bash
# 1. Clone and navigate to project
cd /path/to/claude-devops-tools/projects/2026-09-14_linux-firewall-security

# 2. Setup UFW firewall
sudo bash ufw-setup.sh

# 3. Setup fail2ban protection
sudo bash fail2ban-setup.sh

# 4. Test the configuration
sudo bash test-security.sh

# 5. Monitor in real-time
sudo bash monitor-firewall.sh watch
```

### Option 2: Run in Docker (Recommended for testing)

```bash
# 1. Start the lab environment
docker-compose up -d

# 2. Enter the container
docker exec -it firewall-security-lab bash

# 3. Inside container - Setup firewall
sudo bash /usr/local/bin/ufw-setup.sh

# 4. Inside container - Setup fail2ban
sudo bash /usr/local/bin/fail2ban-setup.sh

# 5. Inside container - Test configuration
sudo bash /usr/local/bin/test-security.sh

# 6. Monitor firewall (in another terminal)
docker exec -it firewall-security-lab bash /usr/local/bin/monitor-firewall.sh watch
```

## What Each Script Does

### `ufw-setup.sh`
- Installs UFW (Uncomplicated Firewall)
- Sets default deny incoming / allow outgoing policies
- Opens SSH, HTTP, HTTPS ports
- Enables rate limiting to prevent brute force
- Enables logging

**Expected output:**
```
[SUCCESS] UFW installed
[SUCCESS] Set default policy: DENY incoming
[SUCCESS] Rate limiting enabled for SSH
[SUCCESS] UFW firewall ENABLED
```

### `fail2ban-setup.sh`
- Installs fail2ban protection system
- Creates jail configuration for SSH (max 5 failed attempts = 10 min ban)
- Enables automatic banning of suspicious IPs
- Creates monitoring jails for HTTP/FTP (optional)

**Expected output:**
```
[SUCCESS] fail2ban installed
[SUCCESS] jail.local created with SSH protection enabled
[SUCCESS] fail2ban enabled and started
```

### `test-security.sh`
- Verifies firewall installation and rules
- Tests port accessibility
- Checks fail2ban jails and bans
- Validates logging is enabled
- Generates security report

**Expected output:**
```
✓ UFW is installed
✓ UFW firewall is ENABLED
✓ SSH port 22 is allowed
✓ Default incoming policy is DENY
✓ No IPs currently banned (system is clean)
```

### `monitor-firewall.sh`
- Shows real-time firewall activity
- Displays banned IPs
- Shows failed login attempts
- Monitors active connections

**Usage:**
```bash
sudo bash monitor-firewall.sh               # Full dashboard
sudo bash monitor-firewall.sh watch         # Auto-refresh every 5s
sudo bash monitor-firewall.sh tail-ufw      # Follow UFW logs
sudo bash monitor-firewall.sh tail-fail2ban # Follow fail2ban logs
sudo bash monitor-firewall.sh banned        # Show banned IPs only
```

## Testing the Security Setup

### 1. Test port blocking
```bash
# These should work
nc -zv 127.0.0.1 22   # SSH - should succeed
nc -zv 127.0.0.1 80   # HTTP - should succeed

# These should be blocked
nc -zv 127.0.0.1 23   # Telnet - should fail
nc -zv 127.0.0.1 111  # NFS - should fail
```

### 2. Test rate limiting
```bash
# Try connecting to SSH rapidly (will be rate limited after 6 attempts in 30s)
for i in {1..10}; do
  ssh -o ConnectTimeout=1 root@127.0.0.1
done
```

### 3. Monitor firewall activity
```bash
# Terminal 1: Watch logs
sudo bash monitor-firewall.sh watch

# Terminal 2: Generate traffic
curl http://127.0.0.1
```

### 4. Simulate failed login attempts
```bash
# From another machine or container
for i in {1..6}; do
  ssh -o StrictHostKeyChecking=no root@target-ip "exit"
done

# After 5 failures, you should be banned for 10 minutes
```

## Verify Everything is Working

```bash
# Check UFW status
sudo ufw status verbose

# Check fail2ban status
sudo fail2ban-client status

# Check SSH jail (should show 0 banned IPs initially)
sudo fail2ban-client status sshd

# View firewall rules
sudo ufw show numbered

# View recent blocked connections
sudo tail -20 /var/log/ufw.log

# View failed login attempts
sudo tail -20 /var/log/auth.log | grep "Failed password"
```

## Docker-Specific Commands

```bash
# View container logs
docker logs firewall-security-lab

# Stop the lab
docker-compose down

# Clean up everything including volumes
docker-compose down -v

# Rebuild container
docker-compose build --no-cache

# Restart services
docker-compose restart
```

## Common Issues

### Issue: "Permission denied" when running scripts
**Solution:** Add `sudo` before the command
```bash
sudo bash ufw-setup.sh
```

### Issue: UFW shows as inactive after reboot
**Solution:** Re-enable it
```bash
sudo ufw enable
```

### Issue: Cannot connect via SSH after firewall setup
**Solution:** The ufw-setup.sh script opens port 22 BEFORE enabling the firewall. If you manually enabled UFW, SSH may be blocked:
```bash
sudo ufw allow 22/tcp
sudo ufw reload
```

### Issue: fail2ban service not starting
**Solution:** Check for configuration errors
```bash
sudo fail2ban-client -d  # Debug check
sudo systemctl status fail2ban  # Check status
sudo tail -f /var/log/fail2ban.log  # View logs
```

## What You Learn

✅ **Firewall concepts**
- How to use UFW to manage iptables rules
- Default policies (deny incoming, allow outgoing)
- Port-based access control
- Rate limiting and DDoS protection

✅ **Intrusion prevention**
- How fail2ban protects against brute force attacks
- Jail configuration and thresholds
- Banning and unbanning IPs
- Monitoring suspicious activity

✅ **System administration**
- Linux networking fundamentals
- SSH security and authentication
- System logging and analysis
- Service management (systemctl)

✅ **DevOps/SRE practices**
- Infrastructure security hardening
- Monitoring and alerting
- Automation and scripting
- Log analysis and troubleshooting

## Next Steps

1. **Advanced UFW:** Configure custom rules for your applications
2. **fail2ban customization:** Create custom jails for your services
3. **Monitoring:** Integrate with Prometheus and Grafana
4. **Alerting:** Set up email notifications for security events
5. **Hardening:** Apply additional security measures (SSH keys, selinux, etc.)

## Resources

- [UFW Documentation](https://wiki.ubuntu.com/UncomplicatedFirewall)
- [fail2ban Official Site](https://www.fail2ban.org/)
- [Linux Security Best Practices](https://wiki.debian.org/SecurityManagement)
- [iptables Tutorial](https://linux.die.net/man/8/iptables)

## Support

For issues or questions:
- Check the README.md for detailed explanations
- Review the shell scripts (well-commented)
- Check logs: `/var/log/ufw.log`, `/var/log/fail2ban.log`, `/var/log/auth.log`
- Run `sudo systemctl status <service>` for service status

---

**Happy learning! 🚀🔒**
