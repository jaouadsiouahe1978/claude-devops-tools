#!/usr/bin/env python3
"""
Script de monitoring et health check pour le service systemd.
Vérifie l'état du service, les logs récents et les statistiques.
"""

import json
import subprocess
import sys
from datetime import datetime, timedelta
from pathlib import Path

STATUS_FILE = Path('/tmp/mon-app/status.json')


def run_command(cmd):
    """Exécuter une commande système."""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        return result.stdout.strip()
    except Exception as e:
        return f"Erreur: {e}"


def check_service_status():
    """Vérifier l'état du service."""
    output = run_command('systemctl status mon-app 2>&1')
    return 'running' in output.lower()


def check_recent_logs():
    """Récupérer les 5 derniers logs."""
    cmd = 'journalctl -u mon-app -n 5 --no-pager'
    return run_command(cmd)


def check_timer_status():
    """Vérifier l'état du timer."""
    cmd = 'systemctl status mon-app.timer --no-pager'
    return run_command(cmd)


def check_last_execution():
    """Vérifier la dernière exécution."""
    if not STATUS_FILE.exists():
        return "Pas d'exécution enregistrée"

    with open(STATUS_FILE) as f:
        status = json.load(f)

    last_run = status.get('last_run')
    if not last_run:
        return "Pas de dernière exécution"

    last_run_time = datetime.fromisoformat(last_run)
    time_ago = datetime.now() - last_run_time

    return f"""
    Dernière exécution: {last_run}
    Il y a: {time_ago}
    Total d'exécutions: {status.get('counter', 0)}
    Tâches traitées: {status.get('tasks_processed', 0)}
    """


def check_resource_usage():
    """Vérifier l'utilisation des ressources."""
    cmd = 'systemctl status mon-app | grep -E "Memory|CPU"'
    return run_command(cmd) or "N/A"


def main():
    """Fonction principale."""
    print("=" * 60)
    print("SYSTEMD SERVICE HEALTH CHECK - mon-app")
    print("=" * 60)

    # État du service
    print("\n1. ÉTAT DU SERVICE")
    print("-" * 60)
    is_running = check_service_status()
    status_str = "✅ RUNNING" if is_running else "❌ STOPPED"
    print(f"Status: {status_str}")

    # État du timer
    print("\n2. ÉTAT DU TIMER")
    print("-" * 60)
    timer_status = check_timer_status()
    print(timer_status[:200] if timer_status else "Timer non trouvé")

    # Dernière exécution
    print("\n3. HISTORIQUE D'EXÉCUTION")
    print("-" * 60)
    print(check_last_execution())

    # Logs récents
    print("\n4. LOGS RÉCENTS")
    print("-" * 60)
    logs = check_recent_logs()
    print(logs if logs else "Pas de logs")

    # Utilisation des ressources
    print("\n5. UTILISATION DES RESSOURCES")
    print("-" * 60)
    resources = check_resource_usage()
    print(resources if resources else "N/A")

    print("\n" + "=" * 60)
    print("FIN DU HEALTH CHECK")
    print("=" * 60)

    return 0 if is_running else 1


if __name__ == '__main__':
    sys.exit(main())
