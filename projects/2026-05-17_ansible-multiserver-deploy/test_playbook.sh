#!/bin/bash
# Script de test pour valider le playbook Ansible

set -e

echo "=== Ansible Playbook Test Suite ==="
echo

echo "1️⃣  Vérifier la syntaxe du playbook..."
ansible-playbook deploy.yml --syntax-check
echo "✓ Syntaxe OK\n"

echo "2️⃣  Vérifier la connectivité des hosts..."
echo "   (Cette étape échouera si les hosts ne sont pas accessibles)"
echo "   ansible all -i inventory.ini -m ping"
echo

echo "3️⃣  Dry-run du playbook (pas de modification)..."
echo "   ansible-playbook deploy.yml -i inventory.ini --check -v"
echo

echo "4️⃣  Déploiement réel..."
echo "   ansible-playbook deploy.yml -i inventory.ini -v"
echo

echo "5️⃣  Vérifier l'idempotence (relancer = 0 changements)..."
echo "   ansible-playbook deploy.yml -i inventory.ini"
echo

echo "=== Configuration Ansible ==="
echo "Fichiers de config trouvés :"
ls -la ansible.cfg inventory.ini 2>/dev/null || echo "Fichiers manquants"
echo

echo "=== Roles ==="
ls -la roles/*/tasks/main.yml || echo "Aucun role trouvé"
echo

echo "=== Variables ==="
echo "Variables globales:"
cat group_vars/all.yml 2>/dev/null || echo "Fichier manquant"
echo

echo "=== Tests Recommandés ==="
echo "• curl http://web1:80/health"
echo "• psql -h db1 -U $db_user -d $db_name"
echo "• systemctl status myapp (sur webservers)"
echo "• systemctl status postgresql (sur databases)"
