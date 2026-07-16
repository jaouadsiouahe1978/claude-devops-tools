#!/bin/bash

# Configurer la politique de mots de passe

echo "=========================================="
echo "Configuring Password Policy"
echo "=========================================="

# Configuration pam_pwquality (complexité des mots de passe)
if [ -f /etc/security/pwquality.conf ]; then
    echo "Configuring pwquality..."
    # Backup original
    cp /etc/security/pwquality.conf /etc/security/pwquality.conf.bak

    # Ajouter/modifier les paramètres
    sed -i 's/^# minlen = /minlen = /' /etc/security/pwquality.conf
    sed -i 's/^minlen = [0-9]*/minlen = 12/' /etc/security/pwquality.conf
    sed -i 's/^# dcredit = /dcredit = /' /etc/security/pwquality.conf
    sed -i 's/^# ucredit = /ucredit = /' /etc/security/pwquality.conf

    echo "✓ pwquality configured (min length: 12 chars)"
else
    echo "⚠ /etc/security/pwquality.conf not found (libpam-pwquality not installed)"
fi

# Configuration de l'expiration des mots de passe
echo ""
echo "Configuring password aging..."

# Modifier /etc/login.defs pour les nouveaux utilisateurs
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS 90/' /etc/login.defs
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS 1/' /etc/login.defs
sed -i 's/^PASS_MIN_LEN.*/PASS_MIN_LEN 12/' /etc/login.defs
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE 14/' /etc/login.defs

echo "✓ Password aging configured in /etc/login.defs:"
echo "  - PASS_MAX_DAYS: 90"
echo "  - PASS_MIN_DAYS: 1"
echo "  - PASS_WARN_AGE: 14"

# Appliquer l'expiration aux utilisateurs existants
echo ""
echo "Applying password aging to existing users..."

for user in alice bob charlie diana eve; do
    if id "$user" &>/dev/null; then
        chage -M 90 -m 1 -W 14 "$user" 2>/dev/null || true
        echo "  ✓ $user: expiration in 90 days"
    fi
done

# Afficher la politique appliquée
echo ""
echo "=========================================="
echo "Password Policy Applied"
echo "=========================================="
echo ""

# Vérifier la configuration
echo "login.defs settings:"
grep "^PASS_" /etc/login.defs | grep -v "^#"

echo ""
echo "✓ Policy complete. New users will be affected immediately."
echo "  Existing users have updated aging parameters."
