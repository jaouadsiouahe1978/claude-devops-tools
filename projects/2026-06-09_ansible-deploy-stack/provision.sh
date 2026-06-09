#!/bin/bash
# Script de provisioning initial pour Ansible

set -e

echo "=== Ansible DevOps Project Provisioning ==="

# Installer Ansible
echo "[1/5] Installation d'Ansible..."
python3 -m pip install --upgrade pip > /dev/null 2>&1
python3 -m pip install ansible docker jinja2 > /dev/null 2>&1

# Vérifier l'installation
echo "[2/5] Vérification d'Ansible..."
ansible --version | head -1

# Installer les dépendances Python
echo "[3/5] Installation des dépendances..."
pip install -r requirements.txt 2>/dev/null || true

# Créer les répertoires
echo "[4/5] Création des répertoires..."
mkdir -p inventory/group_vars
mkdir -p roles/{docker,nginx,postgres,app}/{tasks,templates,files,handlers,defaults}
mkdir -p logs

# Tests de syntaxe
echo "[5/5] Tests de syntaxe des playbooks..."
ansible-playbook --syntax-check site.yml > /dev/null 2>&1 && echo "✓ Syntaxe OK"

echo ""
echo "=== Provisioning Terminé ==="
echo ""
echo "Prochaines étapes :"
echo "1. Modifier inventory/hosts.ini avec vos serveurs"
echo "2. Exécuter: ansible-playbook -i inventory/hosts.ini site.yml --check"
echo "3. Exécuter: ansible-playbook -i inventory/hosts.ini site.yml"
