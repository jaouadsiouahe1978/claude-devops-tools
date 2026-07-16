#!/bin/bash
set -e

# Configurer les ACLs (Access Control Lists)

echo "=========================================="
echo "Setting Up ACLs (Access Control Lists)"
echo "=========================================="

# Vérifier que ACL est supporté
if ! command -v setfacl &> /dev/null; then
    echo "⚠ ACL tools not installed. Installing acl package..."
    apt-get update && apt-get install -y acl 2>/dev/null || yum install -y acl 2>/dev/null || true
fi

echo ""
echo "Scenario 1: Shared project file - multiple users read-only"
echo "---"
# alice, bob, charlie peuvent lire project.txt
setfacl -m u:alice:r /opt/test_permissions/shared/project.txt
setfacl -m u:bob:r /opt/test_permissions/shared/project.txt
setfacl -m u:charlie:r /opt/test_permissions/shared/project.txt
echo "✓ alice, bob, charlie: read-only on project.txt"

echo ""
echo "Scenario 2: Webapp config - only alice can read/write"
echo "---"
setfacl -m u:alice:rw /opt/test_permissions/webapp/config.php
echo "✓ alice: read/write on config.php"

echo ""
echo "Scenario 3: DevOps scripts - devops group read/execute, eve developer can read only"
echo "---"
setfacl -m g:devops:rx /opt/test_permissions/devops/deploy.sh
setfacl -m u:eve:r /opt/test_permissions/devops/deploy.sh
echo "✓ devops group: read/execute on deploy.sh"
echo "✓ eve: read-only on deploy.sh"

echo ""
echo "Scenario 4: Secrets - only diana (senior devops) can access"
echo "---"
# Supprimer l'accès public d'abord
chmod 600 /opt/test_permissions/devops/secrets.env
setfacl -m u:diana:rw /opt/test_permissions/devops/secrets.env
echo "✓ diana: read/write on secrets.env"
echo "✓ autres utilisateurs: NO ACCESS"

echo ""
echo "Scenario 5: Default ACL on directories (new files inherit ACL)"
echo "---"
# ACL par défaut sur répertoire partagé
setfacl -m d:u:alice:rw /opt/test_permissions/shared
setfacl -m d:u:bob:rw /opt/test_permissions/shared
setfacl -m d:g:shared:rx /opt/test_permissions/shared
echo "✓ Default ACL set on /opt/test_permissions/shared"
echo "  New files will inherit: alice(rw), bob(rw), shared group(rx)"

echo ""
echo "=========================================="
echo "ACL Configuration Summary"
echo "=========================================="
echo ""

echo "ACLs on /opt/test_permissions/shared/project.txt:"
getfacl /opt/test_permissions/shared/project.txt | grep -v "^#"

echo ""
echo "ACLs on /opt/test_permissions/webapp/config.php:"
getfacl /opt/test_permissions/webapp/config.php | grep -v "^#"

echo ""
echo "ACLs on /opt/test_permissions/devops/deploy.sh:"
getfacl /opt/test_permissions/devops/deploy.sh | grep -v "^#"

echo ""
echo "ACLs on /opt/test_permissions/devops/secrets.env:"
getfacl /opt/test_permissions/devops/secrets.env | grep -v "^#"

echo ""
echo "Default ACLs on /opt/test_permissions/shared/:"
getfacl /opt/test_permissions/shared | grep "default"

echo ""
echo "✓ ACL setup complete!"
echo ""
echo "Tip: Remove an ACL entry with: setfacl -x u:username /path/to/file"
echo "Tip: Remove all ACLs with: setfacl -b /path/to/file"
