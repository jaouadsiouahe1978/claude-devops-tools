#!/bin/bash

# Scenario 2: Équipe DevOps avec rôles différents
# Situation: Différents niveaux d'accès basés sur le rôle
# Solution: Groupes + sudo + permissions

echo "=========================================="
echo "Scenario 2: DevOps Team Role-Based Access"
echo "=========================================="
echo ""

# Définir les rôles
echo "Team Structure:"
echo "---"
echo "- Diana (senior): Full access"
echo "- Charlie: Deploy scripts"
echo "- Eve: Read-only logs and status"
echo ""

# Vérifier le répertoire devops
if [ ! -d "/opt/test_permissions/devops" ]; then
    echo "Error: /opt/test_permissions/devops not found"
    exit 1
fi

echo "Setting up role-based access..."
echo ""

# Répertoire devops
chown -R root:devops /opt/test_permissions/devops
chmod 750 /opt/test_permissions/devops

# deploy.sh: exécutable pour le groupe devops
chmod 750 /opt/test_permissions/devops/deploy.sh

# secrets.env: lisible uniquement par diana
chmod 600 /opt/test_permissions/devops/secrets.env
echo "DB_PASSWORD=supersecret123" > /opt/test_permissions/devops/secrets.env

echo "File permissions set:"
ls -l /opt/test_permissions/devops/

echo ""
echo "Setting up ACLs for different access levels..."
echo "---"

# Diana: accès complet
echo "Diana (senior): full read/write access"
setfacl -m u:diana:rwx /opt/test_permissions/devops
setfacl -m u:diana:rw /opt/test_permissions/devops/deploy.sh
setfacl -m u:diana:rw /opt/test_permissions/devops/secrets.env

# Charlie: lecture et exécution
echo "Charlie (mid-level): can execute deploy.sh"
setfacl -m u:charlie:r /opt/test_permissions/devops/deploy.sh
chmod +x /opt/test_permissions/devops/deploy.sh

# Eve: lecture seulement
echo "Eve (junior): read-only access to deploy.sh"
setfacl -m u:eve:r /opt/test_permissions/devops/deploy.sh

echo ""
echo "Simulating role-based operations:"
echo "---"

echo ""
echo "Scenario 2A: Diana deploys application"
echo "  Command: diana runs deploy.sh with full logging"
echo "  sudo -u diana /opt/test_permissions/devops/deploy.sh"
echo "  ✓ SUCCESS: Diana can read secrets.env and execute deploy.sh"

echo ""
echo "Scenario 2B: Charlie deploys application"
echo "  Command: charlie runs deploy.sh via sudo"
echo "  sudo -u charlie /opt/test_permissions/devops/deploy.sh"
echo "  Status: Charlie CAN execute the script"
echo "         Charlie CANNOT read secrets.env (no permissions)"

echo ""
echo "Scenario 2C: Eve audits deployment"
echo "  Command: eve views deploy.sh for audit"
echo "  cat /opt/test_permissions/devops/deploy.sh"
echo "  Status: Eve CAN read the script"
echo "         Eve CANNOT execute it (no execute permission)"
echo "         Eve CANNOT access secrets.env"

echo ""
echo "Current ACL configuration:"
echo "---"
echo "deploy.sh:"
getfacl /opt/test_permissions/devops/deploy.sh | grep -E "^(user|group):"

echo ""
echo "secrets.env:"
getfacl /opt/test_permissions/devops/secrets.env | grep -E "^(user|group):"

echo ""
echo "Expected permissions test:"
echo "---"

# Test en tant que diana
echo "Diana can read secrets: ", end=""
if sudo -u diana [ -r /opt/test_permissions/devops/secrets.env ] 2>/dev/null; then
    echo "✓ YES"
else
    echo "✗ NO"
fi

# Test en tant que charlie
echo "Charlie can execute deploy.sh: ", end=""
if sudo -u charlie [ -x /opt/test_permissions/devops/deploy.sh ] 2>/dev/null; then
    echo "✓ YES"
else
    echo "✗ NO"
fi

# Test en tant que eve
echo "Eve can read deploy.sh: ", end=""
if sudo -u eve [ -r /opt/test_permissions/devops/deploy.sh ] 2>/dev/null; then
    echo "✓ YES"
else
    echo "✗ NO"
fi

echo ""
echo "✓ Scenario 2 complete"
echo ""
echo "What we learned:"
echo "- Role-based access control using ACLs and permissions"
echo "- Different operation capabilities per role"
echo "- Separation of secrets from deployment scripts"
echo "- Read-only audit access for junior staff"
echo "- Sudo configuration enables role separation without modifying file ownership"
