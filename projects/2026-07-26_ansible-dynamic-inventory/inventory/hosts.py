#!/usr/bin/env python3
"""
Inventaire dynamique Ansible - Génère une liste d'hôtes en fonction de variables
Ce script remplace un fichier hosts statique par une logique programmatique
Utilisé pour découvrir dynamiquement les serveurs (AWS EC2, GCP, Proxmox, etc.)
"""

import json
import sys
import os

# Configuration fictive pour la démonstration
# En production, cela viendrait d'une API (AWS, Azure, Google Cloud, etc.)

def generate_inventory():
    """Génère l'inventaire dynamique"""

    inventory = {
        "webservers": {
            "hosts": ["web1.example.com", "web2.example.com"],
            "vars": {
                "server_type": "nginx",
                "http_port": 80,
                "max_clients": 200
            }
        },
        "dbservers": {
            "hosts": ["db1.example.com"],
            "vars": {
                "server_type": "postgresql",
                "db_port": 5432,
                "backup_retention": 7
            }
        },
        "monitoring": {
            "hosts": ["monitor1.example.com"],
            "vars": {
                "server_type": "prometheus",
                "metrics_port": 9090,
                "retention_days": 15
            }
        },
        "all": {
            "vars": {
                "ansible_connection": "ssh",
                "ansible_user": "ansible",
                "ansible_become": True,
                "ansible_become_method": "sudo"
            }
        }
    }

    return inventory

def generate_hostvars():
    """Génère les variables spécifiques par hôte"""

    hostvars = {
        "web1.example.com": {
            "ansible_host": "192.168.1.10",
            "server_role": "web",
            "datacenter": "eu-west-1a",
            "environment": "production"
        },
        "web2.example.com": {
            "ansible_host": "192.168.1.11",
            "server_role": "web",
            "datacenter": "eu-west-1b",
            "environment": "production"
        },
        "db1.example.com": {
            "ansible_host": "192.168.1.20",
            "server_role": "database",
            "datacenter": "eu-west-1c",
            "environment": "production",
            "backup_enabled": True
        },
        "monitor1.example.com": {
            "ansible_host": "192.168.1.30",
            "server_role": "monitoring",
            "datacenter": "eu-west-1a",
            "environment": "production"
        }
    }

    return hostvars

def main():
    """Point d'entrée du script d'inventaire"""

    # Mode --list : retourner l'inventaire complet
    if len(sys.argv) == 2 and sys.argv[1] == '--list':
        inventory = generate_inventory()
        hostvars = generate_hostvars()
        inventory['_meta'] = {'hostvars': hostvars}
        print(json.dumps(inventory, indent=2))
        sys.exit(0)

    # Mode --host <hostname> : retourner les variables d'un hôte spécifique
    elif len(sys.argv) == 3 and sys.argv[1] == '--host':
        hostname = sys.argv[2]
        hostvars = generate_hostvars()
        if hostname in hostvars:
            print(json.dumps(hostvars[hostname], indent=2))
        else:
            print(json.dumps({}))
        sys.exit(0)

    else:
        print("Usage: hosts.py --list | hosts.py --host <hostname>", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()
