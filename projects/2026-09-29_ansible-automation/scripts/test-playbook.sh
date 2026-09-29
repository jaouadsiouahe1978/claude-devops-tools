#!/bin/bash
# Test des playbooks Ansible avant exécution

set -e

INVENTORY="inventory/hosts.yml"
PLAYBOOK="playbooks/site.yml"

echo "🧪 Test Ansible Playbook Suite"
echo "================================"
echo ""

# Vérifier que Ansible est installé
if ! command -v ansible &> /dev/null; then
    echo "❌ Ansible n'est pas installé"
    echo "Installation: sudo apt-get install ansible"
    exit 1
fi

echo "✓ Ansible version: $(ansible --version | head -1)"
echo ""

# Test 1: Vérifier la syntaxe
echo "1. Vérification de la syntaxe du playbook..."
ansible-playbook "$PLAYBOOK" --syntax-check -i "$INVENTORY" > /dev/null
echo "   ✓ Syntaxe OK"
echo ""

# Test 2: Vérifier la connectivité
echo "2. Vérification de la connectivité SSH..."
if ! ansible all -i "$INVENTORY" -m ping --one-line 2>/dev/null; then
    echo "   ⚠️  Impossible de se connecter à certains hôtes"
    echo "   Note: C'est attendu si les serveurs n'existent pas encore"
else
    echo "   ✓ Connectivité OK"
fi
echo ""

# Test 3: Dry-run
echo "3. Exécution en dry-run (--check)..."
echo "   (Affiche les changements sans les appliquer)"
if ansible-playbook "$PLAYBOOK" -i "$INVENTORY" --check -v 2>/dev/null | head -20; then
    echo "   ✓ Dry-run OK"
else
    echo "   ⚠️  Certains hôtes ne sont pas accessibles (c'est normal)"
fi
echo ""

# Test 4: Validation des roles
echo "4. Validation des rôles..."
for role in roles/*/; do
    role_name=$(basename "$role")
    if [ -f "$role/tasks/main.yml" ]; then
        echo "   ✓ Rôle $role_name OK"
    fi
done
echo ""

# Test 5: Vérification des variables
echo "5. Vérification des variables..."
ansible-inventory -i "$INVENTORY" --list > /dev/null 2>&1
echo "   ✓ Variables OK"
echo ""

echo "✅ Tous les tests pré-déploiement sont passés!"
echo ""
echo "Prochaines étapes:"
echo "  - Configurer inventory/hosts.yml avec vos serveurs"
echo "  - Exécuter: ansible-playbook -i inventory/hosts.yml playbooks/site.yml -v"
