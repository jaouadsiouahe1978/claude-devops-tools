#!/usr/bin/env python3
"""
Application simple à managéer par systemd.
Simule un worker qui traite des tâches et enregistre son activité.
"""

import sys
import json
import logging
import time
from datetime import datetime
from pathlib import Path

# Configuration du logging - compatible avec journalctl
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    stream=sys.stdout
)
logger = logging.getLogger('mon-app')

# Répertoire de données
DATA_DIR = Path('/tmp/mon-app')
DATA_DIR.mkdir(exist_ok=True)
STATUS_FILE = DATA_DIR / 'status.json'


def load_status():
    """Charger le statut actuel."""
    if STATUS_FILE.exists():
        with open(STATUS_FILE) as f:
            return json.load(f)
    return {'counter': 0, 'last_run': None, 'tasks_processed': 0}


def save_status(status):
    """Sauvegarder le statut."""
    with open(STATUS_FILE, 'w') as f:
        json.dump(status, f, indent=2)


def process_task(task_id):
    """Simuler le traitement d'une tâche."""
    logger.info(f"Traitement de la tâche {task_id}...")
    time.sleep(0.5)  # Simuler du travail
    logger.info(f"Tâche {task_id} complétée avec succès")
    return True


def main():
    """Fonction principale."""
    logger.info("=== Démarrage de l'application ===")

    status = load_status()
    status['counter'] += 1
    status['last_run'] = datetime.now().isoformat()

    logger.info(f"Exécution #{status['counter']}")
    logger.info(f"Tâches traitées jusqu'à présent: {status['tasks_processed']}")

    # Traiter quelques tâches
    num_tasks = 3
    for i in range(num_tasks):
        if process_task(status['counter'] * 10 + i):
            status['tasks_processed'] += 1

    save_status(status)
    logger.info(f"Checkpoint: {status['counter']} exécutions, {status['tasks_processed']} tâches")
    logger.info("=== Application terminée avec succès ===")

    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except Exception as e:
        logger.error(f"Erreur: {e}", exc_info=True)
        sys.exit(1)
