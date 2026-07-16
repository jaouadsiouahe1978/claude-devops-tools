#!/bin/bash

# Audit de la configuration sudo

echo "=========================================="
echo "Sudo Configuration Audit"
echo "=========================================="
echo ""

# Afficher les permissions de chaque utilisateur
echo "User Sudo Permissions:"
echo "---"

for user in alice bob charlie diana eve; do
    if id "$user" &>/dev/null; then
        echo ""
        echo "User: $user"
        sudo -l -U "$user" 2>/dev/null | grep -v "^  (root)" | tail -n +2
    fi
done

echo ""
echo "==========================================="
echo "Group Sudo Permissions:"
echo "---"

echo ""
echo "Group: webapp"
grep "%webapp" /etc/sudoers.d/devops 2>/dev/null || echo "  (no entries)"

echo ""
echo "Group: devops"
grep "%devops" /etc/sudoers.d/devops 2>/dev/null || echo "  (no entries)"

echo ""
echo "Group: developer"
grep "%developer" /etc/sudoers.d/devops 2>/dev/null || echo "  (no entries)"

echo ""
echo "==========================================="
echo "Sudo Log Analysis"
echo "---"

if [ -f /var/log/sudo.log ]; then
    echo "Recent sudo commands (last 10):"
    tail -10 /var/log/sudo.log | while read -r line; do
        echo "  $line"
    done
else
    echo "  /var/log/sudo.log not found (logging not yet enabled)"
fi

echo ""
echo "==========================================="
echo "Security Checks"
echo "---"

# Vérifier les configurations dangereuses
echo ""
echo "Checking for NOPASSWD entries..."
if grep -q "NOPASSWD" /etc/sudoers.d/devops 2>/dev/null; then
    echo "  ⚠ NOPASSWD entries found (users marked with 'no password requirement'):"
    grep "NOPASSWD" /etc/sudoers.d/devops | sed 's/^/    /'
else
    echo "  ✓ No NOPASSWD entries"
fi

echo ""
echo "Checking for unrestricted sudo (ALL) entries..."
grep "ALL.*ALL" /etc/sudoers.d/devops 2>/dev/null | while read -r line; do
    if [[ "$line" =~ "diana" ]]; then
        echo "  ⚠ Unrestricted access for diana (intended for senior admin)"
    fi
done

echo ""
echo "Sudo file permissions:"
ls -l /etc/sudoers* 2>/dev/null | awk '{printf "  %s %s\n", $1, $NF}'

echo ""
echo "✓ Audit complete"
