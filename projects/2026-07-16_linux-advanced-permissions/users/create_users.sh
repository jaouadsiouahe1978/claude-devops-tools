#!/bin/bash
set -e

# Créer utilisateurs et groupes pour les scénarios

echo "=========================================="
echo "Creating Users and Groups"
echo "=========================================="

# Définir les utilisateurs
USERS=(
    "alice:webapp"
    "bob:webapp"
    "charlie:devops"
    "diana:devops"
    "eve:developer"
)

# Créer les groupes
echo "Créating groups..."
groupadd -f webapp 2>/dev/null || true
groupadd -f devops 2>/dev/null || true
groupadd -f developer 2>/dev/null || true
groupadd -f shared 2>/dev/null || true

echo "✓ Groupes créés: webapp, devops, developer, shared"

# Créer les utilisateurs
echo ""
echo "Creating users..."

for user_info in "${USERS[@]}"; do
    USERNAME=$(echo "$user_info" | cut -d: -f1)
    USERGROUP=$(echo "$user_info" | cut -d: -f2)

    if id "$USERNAME" &>/dev/null; then
        echo "  ⚠ $USERNAME already exists"
    else
        useradd -m -s /bin/bash -G "$USERGROUP" "$USERNAME"
        # Définir mot de passe (demo: password123)
        echo "$USERNAME:password123" | chpasswd 2>/dev/null || true
        echo "  ✓ $USERNAME created (group: $USERGROUP)"
    fi
done

# Ajouter utilisateurs supplémentaires aux groupes
echo ""
echo "Adding users to shared group..."
usermod -aG shared alice 2>/dev/null || true
usermod -aG shared bob 2>/dev/null || true
usermod -aG shared charlie 2>/dev/null || true

echo "✓ Users added to shared group"

# Afficher résumé
echo ""
echo "=========================================="
echo "Users and Groups Summary"
echo "=========================================="
echo ""
echo "Users created:"
getent passwd alice bob charlie diana eve 2>/dev/null | awk -F: '{printf "  %-10s (UID: %d, GID: %d)\n", $1, $3, $4}'

echo ""
echo "Groups:"
getent group webapp devops developer shared 2>/dev/null | while IFS=: read -r name _ gid members; do
    echo "  $name (GID: $gid) - Members: $members"
done

echo ""
echo "✓ Setup completed!"
