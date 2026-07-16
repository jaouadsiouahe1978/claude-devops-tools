#!/bin/bash
set -e

# Configurer les permissions standards (rwx)

echo "=========================================="
echo "Setting Up Standard Permissions (rwx)"
echo "=========================================="

# Répertoire partagé
echo ""
echo "Setting up /opt/test_permissions/shared (shared group)..."
chown -R root:shared /opt/test_permissions/shared
chmod 750 /opt/test_permissions/shared
chmod 644 /opt/test_permissions/shared/*
echo "  ✓ Permissions: dr-xr-x--- (750)"
echo "  ✓ Owner: root:shared"

# Répertoire webapp
echo ""
echo "Setting up /opt/test_permissions/webapp (webapp group)..."
chown -R root:webapp /opt/test_permissions/webapp
chmod 750 /opt/test_permissions/webapp
chmod 640 /opt/test_permissions/webapp/*
echo "  ✓ Permissions: dr-xr-x--- (750)"
echo "  ✓ Owner: root:webapp"

# Répertoire devops
echo ""
echo "Setting up /opt/test_permissions/devops (devops group)..."
chown -R root:devops /opt/test_permissions/devops
chmod 750 /opt/test_permissions/devops
chmod 640 /opt/test_permissions/devops/*
echo "  ✓ Permissions: dr-xr-x--- (750)"
echo "  ✓ Owner: root:devops"

# Afficher les permissions appliquées
echo ""
echo "=========================================="
echo "Applied Permissions"
echo "=========================================="
echo ""

ls -ld /opt/test_permissions/shared
ls -ld /opt/test_permissions/webapp
ls -ld /opt/test_permissions/devops

echo ""
echo "File permissions:"
ls -l /opt/test_permissions/shared/
echo ""
ls -l /opt/test_permissions/webapp/
echo ""
ls -l /opt/test_permissions/devops/

echo ""
echo "✓ Standard permissions setup complete"
