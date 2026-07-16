#!/bin/bash
set -e

# Setup complet: créer les structures de répertoires et fichiers de test

echo "============================================"
echo "Linux Advanced Permissions - Full Setup"
echo "============================================"

# Créer répertoires
mkdir -p /opt/test_permissions/shared
mkdir -p /opt/test_permissions/webapp
mkdir -p /opt/test_permissions/devops
mkdir -p /var/log/permission-audit
mkdir -p /tmp/permission-backups

# Créer fichiers de test
touch /opt/test_permissions/shared/project.txt
touch /opt/test_permissions/webapp/config.php
touch /opt/test_permissions/webapp/index.html
touch /opt/test_permissions/devops/deploy.sh
touch /opt/test_permissions/devops/secrets.env

# Définir propriétaires et permissions initiales
chown root:root /opt/test_permissions
chmod 755 /opt/test_permissions

# Backup sudoers original
cp /etc/sudoers /tmp/permission-backups/sudoers.backup.$(date +%s)

echo "✓ Répertoires créés: /opt/test_permissions"
echo "✓ Fichiers de test créés"
echo "✓ Backup sudoers effectué: /tmp/permission-backups/"
echo ""
echo "Exécutez maintenant les scripts dans l'ordre:"
echo "1. sudo ./users/create_users.sh"
echo "2. sudo ./users/password_policy.sh"
echo "3. ./users/user_audit.sh"
echo "4. sudo ./permissions/standard_permissions.sh"
echo "5. sudo ./permissions/acl_setup.sh"
echo "6. ./permissions/acl_audit.sh"
echo "7. sudo ./sudoers/setup_sudo.sh"
echo "8. ./sudoers/sudo_audit.sh"
echo "9. sudo ./scenarios/scenario1_webapp_access.sh"
