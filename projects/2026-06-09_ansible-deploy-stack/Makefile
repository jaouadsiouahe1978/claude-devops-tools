.PHONY: help install check deploy deploy-check test clean

help:
	@echo "Ansible DevOps Project - Available Commands"
	@echo ""
	@echo "  make install      - Installer Ansible et dépendances"
	@echo "  make check        - Vérifier la syntaxe des playbooks"
	@echo "  make deploy-check - Exécuter un dry-run du déploiement"
	@echo "  make deploy       - Exécuter le déploiement complet"
	@echo "  make deploy-app   - Redéployer uniquement l'application"
	@echo "  make test         - Exécuter les tests"
	@echo "  make clean        - Nettoyer les fichiers générés"

install:
	@echo "Installation d'Ansible..."
	pip install -r requirements.txt

check:
	@echo "Vérification de la syntaxe des playbooks..."
	ansible-playbook --syntax-check site.yml
	ansible-playbook --syntax-check deploy.yml

deploy-check:
	@echo "Exécution du dry-run..."
	ansible-playbook -i inventory/hosts.ini site.yml --check

deploy:
	@echo "Déploiement complet..."
	ansible-playbook -i inventory/hosts.ini site.yml -v

deploy-app:
	@echo "Redéploiement de l'application..."
	ansible-playbook -i inventory/hosts.ini deploy.yml -v

test:
	@echo "Exécution des tests..."
	@echo "Vérification de la syntaxe..."
	ansible-playbook --syntax-check site.yml
	@echo "Tests POST-déploiement..."
	ansible -i inventory/hosts.ini all -m ping

clean:
	@echo "Nettoyage..."
	rm -rf /tmp/ansible.log
	find . -name "*.pyc" -delete
	find . -name "__pycache__" -delete
	@echo "✓ Nettoyage terminé"
