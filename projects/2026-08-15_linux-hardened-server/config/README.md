# Configuration Examples

This directory contains example configuration files for reference:

- **sshd_config.example** - Hardened SSH server configuration
- **sudoers.example** - Sudo access control configuration
- **fail2ban_jail.conf.example** - Fail2ban jail settings
- **audit.rules.example** - System audit rules

These are automatically applied by the setup scripts, but you can review them here for customization.

## Key Points

1. **SSH Config**: Uses strong ciphers, disables root login, requires key-based auth
2. **Sudoers**: Restricts sudo access with logging and rate limiting
3. **Fail2ban**: Protects SSH with automatic IP banning after failed attempts
4. **Audit Rules**: Monitors critical system files and administrative actions

Always use `visudo` to edit sudoers files to validate syntax!
