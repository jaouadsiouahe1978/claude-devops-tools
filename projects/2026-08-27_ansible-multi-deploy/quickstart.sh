#!/bin/bash
# Quickstart pour Ansible - Multi Serveurs Deployment
# Ce script aide au démarrage rapide du projet

set -e

echo "╔═════════════════════════════════════════════════════════════╗"
echo "║          Ansible Multi-Serveurs - Quickstart               ║"
echo "╚═════════════════════════════════════════════════════════════╝"
echo ""

# Vérifier Ansible
if ! command -v ansible &> /dev/null; then
    echo "❌ Ansible n'est pas installé."
    echo "Installation: sudo apt-get install -y ansible"
    exit 1
fi

echo "✓ Ansible trouvé: $(ansible --version | head -1)"
echo ""

# Créer le répertoire logs
mkdir -p logs
echo "✓ Répertoire logs/ créé"

# Vérifier l'inventaire
echo ""
echo "📋 Inventaire actuel:"
ansible-inventory --list | head -20
echo ""

# Syntaxe check
echo "🔍 Vérification syntaxe playbooks..."
ansible-playbook playbooks/site.yml --syntax-check > /dev/null
echo "✓ Syntaxe OK"

echo ""
echo "📝 Prochaines étapes:"
echo "  1. Éditer l'inventaire: inventory/hosts.ini"
echo "  2. Tester connexion SSH: ansible all -m ping"
echo "  3. Exécuter le setup: ansible-playbook playbooks/site.yml --check"
echo "  4. Déployer: ansible-playbook playbooks/site.yml"
echo ""
echo "📚 Documentation: README.md"
