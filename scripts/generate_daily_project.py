#!/usr/bin/env python3
"""Générateur automatique de projets DevOps quotidiens"""
import os, json, subprocess, sys
from datetime import datetime
from pathlib import Path

PROJECTS_DIR = Path(__file__).parent.parent / "projects"
PROJECTS_DIR.mkdir(parents=True, exist_ok=True)

THEMES = [
    {"id": "docker-app", "name": "Docker Multi-Container App", "desc": "Conteneuriser une application avec Docker Compose", "tech": ["Docker", "Compose"], "files": {"docker-compose.yml": "version: '3.8'\nservices:\n  web:\n    image: nginx:latest\n    ports:\n      - '80:80'\n  db:\n    image: postgres:15\n    environment:\n      POSTGRES_PASSWORD: secret\n"}},
    {"id": "k8s-deploy", "name": "Kubernetes Deployment", "desc": "Déployer sur Kubernetes avec manifests", "tech": ["Kubernetes", "kubectl"], "files": {"deployment.yaml": "apiVersion: apps/v1\nkind: Deployment\nmetadata:\n  name: webapp\nspec:\n  replicas: 3\n  template:\n    spec:\n      containers:\n      - name: web\n        image: nginx:latest\n"}},
    {"id": "ci-cd-github", "name": "GitHub Actions Pipeline", "desc": "Pipeline CI/CD avec GitHub Actions", "tech": ["GitHub", "CI/CD"], "files": {".github/workflows/ci.yml": "name: CI\non: [push, pull_request]\njobs:\n  test:\n    runs-on: ubuntu-latest\n    steps:\n    - uses: actions/checkout@v3\n    - run: npm install && npm test\n"}},
    {"id": "terraform-iac", "name": "Terraform AWS", "desc": "Infrastructure as Code avec Terraform", "tech": ["Terraform", "AWS"], "files": {"main.tf": "provider \"aws\" {\n  region = \"eu-west-1\"\n}\nresource \"aws_vpc\" \"main\" {\n  cidr_block = \"10.0.0.0/16\"\n}\n"}},
    {"id": "ansible-config", "name": "Ansible Playbook", "desc": "Automatiser avec Ansible", "tech": ["Ansible", "YAML"], "files": {"playbook.yml": "---\n- name: Configure servers\n  hosts: all\n  tasks:\n  - name: Install Nginx\n    apt: name=nginx state=present\n"}},
    {"id": "prometheus-monitor", "name": "Prometheus Monitoring", "desc": "Monitoring avec Prometheus & Grafana", "tech": ["Prometheus", "Grafana"], "files": {"prometheus.yml": "global:\n  scrape_interval: 15s\nscrape_configs:\n  - job_name: prometheus\n    static_configs:\n      - targets: ['localhost:9090']\n"}},
    {"id": "bash-tools", "name": "Bash Scripts", "desc": "Scripts d'administration système", "tech": ["Bash", "Linux"], "files": {"backup.sh": "#!/bin/bash\nset -euo pipefail\necho 'Backing up...'\ntar -czf backup_$(date +%s).tar.gz /data\necho 'Done!'\n"}},
    {"id": "python-tools", "name": "Python DevOps Tools", "desc": "Outils DevOps en Python", "tech": ["Python", "Automation"], "files": {"monitor.py": "#!/usr/bin/env python3\nimport requests\nimport time\n\nwhile True:\n    r = requests.get('http://localhost:8000/health')\n    print(f'Status: {r.status_code}')\n    time.sleep(5)\n"}},
    {"id": "jenkins-pipeline", "name": "Jenkins Pipeline", "desc": "Pipeline Jenkins déclaratif", "tech": ["Jenkins", "CI/CD"], "files": {"Jenkinsfile": "pipeline {\n    agent any\n    stages {\n        stage('Build') { steps { sh 'npm run build' } }\n        stage('Test') { steps { sh 'npm test' } }\n    }\n}\n"}},
    {"id": "elk-logging", "name": "ELK Stack", "desc": "Centralisation des logs avec ELK", "tech": ["Elasticsearch", "Kibana"], "files": {"docker-compose.yml": "version: '3.8'\nservices:\n  elasticsearch:\n    image: docker.elastic.co/elasticsearch/elasticsearch:8.5.0\n  kibana:\n    image: docker.elastic.co/kibana/kibana:8.5.0\n    ports: ['5601:5601']\n"}},
]

def get_theme():
    day = datetime.now().timetuple().tm_yday
    return THEMES[(day - 1) % len(THEMES)]

def create_readme(theme):
    return f"""# {theme['name']}

## 📚 Objectif
{theme['desc']}

## 🛠️ Technologies
- {', '.join(theme['tech'])}

## 🚀 Installation
```bash
cd projects/{datetime.now().strftime('%Y-%m-%d')}_{theme['id']}
# Instructions spécifiques au projet
```

## 📖 Ce qu'on apprend
- Configuration avec {theme['tech'][0]}
- Bonnes pratiques DevOps
- Infrastructure as Code

---
**Créé le:** {datetime.now().strftime('%Y-%m-%d')}
**Durée:** 1 journée
**Niveau:** Débutant à Intermédiaire
"""

def create_project():
    theme = get_theme()
    today = datetime.now().strftime("%Y-%m-%d")
    project_name = f"{today}_{theme['id']}"
    project_dir = PROJECTS_DIR / project_name
    
    if project_dir.exists():
        print(f"⚠️  {project_name} existe déjà")
        return None
    
    project_dir.mkdir(parents=True, exist_ok=True)
    
    for file_path, content in theme['files'].items():
        full_path = project_dir / file_path
        full_path.parent.mkdir(parents=True, exist_ok=True)
        with open(full_path, "w") as f:
            f.write(content)
        print(f"✓ {file_path}")
    
    with open(project_dir / "README.md", "w") as f:
        f.write(create_readme(theme))
    print("✓ README.md")
    
    return {"name": project_name, "theme": theme}

def git_ops(project):
    try:
        os.chdir(PROJECTS_DIR.parent)
        subprocess.run(["git", "add", f"projects/{project['name']}"], check=True, capture_output=True)
        subprocess.run(["git", "commit", "-m", f"Add {project['name']}: {project['theme']['name']}"], check=True, capture_output=True)
        subprocess.run(["git", "push", "origin", "main"], check=True, capture_output=True, timeout=30)
        print("✓ Git commit & push")
        return True
    except Exception as e:
        print(f"✗ Git error: {e}")
        return False

def notify():
    try:
        import requests
        theme = get_theme()
        tech = ", ".join(theme['tech'][:2])
        response = requests.post(
            "https://ntfy.sh/jaouad-devops-veille",
            headers={"Title": "DevOps du jour ✨", "Priority": "default", "Tags": "devops,linux"},
            data=f"{theme['name']} - {tech}\n\n{theme['desc']}",
            timeout=10
        )
        if response.status_code == 200:
            print("✓ Notification sent")
    except:
        pass

if __name__ == "__main__":
    print("🚀 Daily DevOps Project Generator\n")
    project = create_project()
    if project:
        print(f"\n📦 {project['name']}")
        print(f"📝 {project['theme']['name']}")
        git_ops(project)
        notify()
        print("\n✅ Succès!")
