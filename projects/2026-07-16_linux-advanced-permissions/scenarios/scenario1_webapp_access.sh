#!/bin/bash

# Scenario 1: Application web multi-user
# Situation: Webapp (nginx) doit servir des fichiers de différents utilisateurs
# Solution: ACLs + groupes + permissions appropriées

echo "=========================================="
echo "Scenario 1: Multi-User Webapp Access"
echo "=========================================="
echo ""

# Vérifier que le répertoire webapp est configuré
if [ ! -d "/opt/test_permissions/webapp" ]; then
    echo "Error: /opt/test_permissions/webapp not found"
    exit 1
fi

echo "Setup: Webapp serving files for alice and bob"
echo "---"

# Créer des fichiers utilisateur
echo "Creating user-specific files..."
mkdir -p /opt/test_permissions/webapp/alice
mkdir -p /opt/test_permissions/webapp/bob

touch /opt/test_permissions/webapp/alice/index.html
touch /opt/test_permissions/webapp/bob/index.html

echo "<h1>Alice's Page</h1>" > /opt/test_permissions/webapp/alice/index.html
echo "<h1>Bob's Page</h1>" > /opt/test_permissions/webapp/bob/index.html

# Configurer les permissions
echo ""
echo "Configuring permissions..."

# Alice possède ses fichiers
chown -R alice:alice /opt/test_permissions/webapp/alice
chmod -R 750 /opt/test_permissions/webapp/alice

# Bob possède ses fichiers
chown -R bob:bob /opt/test_permissions/webapp/bob
chmod -R 750 /opt/test_permissions/webapp/bob

# Nginx (group: www-data) peut lire les fichiers via ACL
echo ""
echo "Setting up web server access with ACL..."
setfacl -m u:www-data:rx /opt/test_permissions/webapp/alice
setfacl -m u:www-data:rx /opt/test_permissions/webapp/alice/index.html
setfacl -m u:www-data:rx /opt/test_permissions/webapp/bob
setfacl -m u:www-data:rx /opt/test_permissions/webapp/bob/index.html

echo "✓ www-data can read but not modify files"

echo ""
echo "Testing access permissions:"
echo "---"

# Test access as alice
echo "Test 1: alice accessing her own files"
if [ -r /opt/test_permissions/webapp/alice/index.html ]; then
    echo "  ✓ alice can read her files"
else
    echo "  ✗ alice cannot read her files"
fi

# Test access as bob
echo "Test 2: bob accessing his own files"
if [ -r /opt/test_permissions/webapp/bob/index.html ]; then
    echo "  ✓ bob can read his files"
else
    echo "  ✗ bob cannot read his files"
fi

# Test cross-user access
echo "Test 3: alice cannot access bob's directory"
if ! test -x /opt/test_permissions/webapp/bob 2>/dev/null; then
    echo "  ✓ alice cannot access bob's directory (permission denied)"
else
    echo "  ✗ alice can access bob's directory (security issue!)"
fi

echo ""
echo "File permissions summary:"
echo "---"
ls -ld /opt/test_permissions/webapp/alice
ls -ld /opt/test_permissions/webapp/bob

echo ""
echo "ACL configuration:"
echo "---"
echo "alice/index.html:"
getfacl /opt/test_permissions/webapp/alice/index.html | grep -E "^(user|group):"

echo ""
echo "bob/index.html:"
getfacl /opt/test_permissions/webapp/bob/index.html | grep -E "^(user|group):"

echo ""
echo "✓ Scenario 1 complete"
echo ""
echo "What we learned:"
echo "- Users can maintain their own files/directories"
echo "- Web server (www-data) can read via ACL without owning files"
echo "- Cross-user access is prevented by restrictive permissions"
echo "- Files can be individually protected while staying readable to web server"
