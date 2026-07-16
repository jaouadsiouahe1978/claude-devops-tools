#!/bin/bash
set -e

# Configurer sudo de manière sécurisée avec visudo

echo "=========================================="
echo "Setting Up Advanced Sudo Configuration"
echo "=========================================="

# Créer un fichier temporaire avec les nouvelles configurations
TEMP_SUDOERS=$(mktemp)

cat > "$TEMP_SUDOERS" << 'SUDOERS_EOF'

# Webapp group - restart nginx with password
%webapp ALL=(root) /usr/sbin/systemctl restart nginx

# DevOps group - manage services without password
%devops ALL=(root) NOPASSWD: /usr/sbin/systemctl start *, /usr/sbin/systemctl stop *, /usr/sbin/systemctl restart *, /usr/sbin/systemctl status *

# Developer group - limited permissions
%developer ALL=(root) NOPASSWD: /usr/bin/journalctl -u * -f, /bin/systemctl status *

# Alice - webapp admin
alice ALL=(root) NOPASSWD: /usr/bin/nano /opt/test_permissions/webapp/config.php, /usr/bin/vi /opt/test_permissions/webapp/config.php, /usr/bin/vim /opt/test_permissions/webapp/config.php

# Charlie - devops automation
charlie ALL=(root) NOPASSWD: /opt/test_permissions/devops/deploy.sh

# Diana - senior devops (full access)
diana ALL=(ALL) NOPASSWD: ALL

# Eve - junior developer (logs only)
eve ALL=(root) NOPASSWD: /usr/bin/tail -f /var/log/*, /usr/bin/journalctl

# Bob - backup operations
bob ALL=(root) NOPASSWD: /usr/bin/tar, /usr/bin/rsync, /usr/bin/find /opt/test_permissions -type f -name "*.bak"

# Security defaults
Defaults use_pty
Defaults log_file="/var/log/sudo.log"
Defaults env_reset
Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
Defaults passwd_timeout=0
Defaults timestamp_timeout=5

SUDOERS_EOF

# Vérifier la syntaxe avec visudo
echo ""
echo "Validating sudoers syntax..."
if visudo -c -f "$TEMP_SUDOERS" &>/dev/null; then
    echo "✓ Syntax is valid"
else
    echo "✗ Syntax error detected!"
    cat "$TEMP_SUDOERS"
    rm "$TEMP_SUDOERS"
    exit 1
fi

# Ajouter les nouvelles configurations au fichier sudoers existant
# On ajoute seulement si les lignes ne sont pas déjà présentes
echo ""
echo "Adding configurations to /etc/sudoers.d/devops..."

# Créer un fichier dans sudoers.d (plus sûr que d'éditer sudoers directement)
cat > /etc/sudoers.d/devops << 'SUDOERS_EOF'

# Webapp group - restart nginx with password
%webapp ALL=(root) /usr/sbin/systemctl restart nginx

# DevOps group - manage services without password
%devops ALL=(root) NOPASSWD: /usr/sbin/systemctl start *, /usr/sbin/systemctl stop *, /usr/sbin/systemctl restart *, /usr/sbin/systemctl status *

# Developer group - limited permissions
%developer ALL=(root) NOPASSWD: /usr/bin/journalctl -u * -f, /bin/systemctl status *

# Alice - webapp admin
alice ALL=(root) NOPASSWD: /usr/bin/nano /opt/test_permissions/webapp/config.php, /usr/bin/vi /opt/test_permissions/webapp/config.php, /usr/bin/vim /opt/test_permissions/webapp/config.php

# Charlie - devops automation
charlie ALL=(root) NOPASSWD: /opt/test_permissions/devops/deploy.sh

# Diana - senior devops (full access)
diana ALL=(ALL) NOPASSWD: ALL

# Eve - junior developer (logs only)
eve ALL=(root) NOPASSWD: /usr/bin/tail -f /var/log/*, /usr/bin/journalctl

# Bob - backup operations
bob ALL=(root) NOPASSWD: /usr/bin/tar, /usr/bin/rsync, /usr/bin/find /opt/test_permissions -type f -name "*.bak"

SUDOERS_EOF

chmod 0440 /etc/sudoers.d/devops

# Valider la syntaxe du fichier sudoers.d
if visudo -c -f /etc/sudoers.d/devops &>/dev/null; then
    echo "✓ /etc/sudoers.d/devops created and validated"
else
    echo "✗ Error in sudoers file!"
    rm /etc/sudoers.d/devops
    rm "$TEMP_SUDOERS"
    exit 1
fi

# Configurer les logs sudo
echo ""
echo "Setting up sudo logging..."

if [ ! -f /etc/rsyslog.d/sudo.conf ]; then
    cat > /etc/rsyslog.d/sudo.conf << 'RSYSLOG_EOF'
:programname, isequal, "sudo" /var/log/sudo.log
& stop
RSYSLOG_EOF
    systemctl restart rsyslog 2>/dev/null || service rsyslog restart 2>/dev/null || true
    echo "✓ Sudo logging configured in /var/log/sudo.log"
else
    echo "✓ Sudo logging already configured"
fi

rm "$TEMP_SUDOERS"

echo ""
echo "=========================================="
echo "Sudo Configuration Applied"
echo "=========================================="
echo ""
echo "User permissions:"
echo "  alice:      Can edit webapp config (no password)"
echo "  bob:        Can run tar, rsync, find (no password)"
echo "  charlie:    Can run deploy.sh (no password)"
echo "  diana:      Full sudo access (no password)"
echo "  eve:        Can view logs (no password)"
echo ""
echo "Group permissions:"
echo "  %webapp:    Can restart nginx (with password)"
echo "  %devops:    Can manage services (no password)"
echo "  %developer: Can view logs and status (no password)"
echo ""
echo "Testing sudo access:"
echo "  sudo -l -U alice"
echo "  sudo -l -U bob"
echo "  sudo -l -U charlie"
echo "  sudo -l -U diana"
echo "  sudo -l -U eve"
echo ""
echo "✓ Setup complete!"
