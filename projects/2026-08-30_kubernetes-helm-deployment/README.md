# Kubernetes Multi-Environment Deployment avec Helm

## Description
Déployer une application web multi-tiers sur Kubernetes avec **Helm charts** pour gérer les déploiements sur plusieurs environnements (dev, staging, production).

## Objectif Pédagogique
- ✅ Comprendre Kubernetes et les concepts de pods, services, deployments
- ✅ Maîtriser Helm pour templater et gérer les déploiements
- ✅ Implémenter la gestion multi-environnements avec values.yaml
- ✅ Utiliser Minikube pour tester localement
- ✅ Configurer des stratégies de déploiement (rolling updates, resources limits)

## Technos Utilisées
- **Kubernetes** : Orchestration de conteneurs
- **Helm** : Package manager pour Kubernetes
- **Minikube** : Cluster Kubernetes local
- **Docker** : Containerisation de l'application
- **Bash** : Scripts d'automatisation

## Pré-requis
- Docker installé
- Minikube installé (`minikube start`)
- Helm 3+ installé
- kubectl configuré

## Structure du Projet
```
2026-08-30_kubernetes-helm-deployment/
├── README.md
├── app/
│   ├── Dockerfile              # Image Docker de l'app
│   ├── app.py                  # Application Python simple
│   └── requirements.txt         # Dépendances Python
├── helm/
│   └── myapp/
│       ├── Chart.yaml           # Métadonnées du chart
│       ├── values.yaml          # Valeurs par défaut
│       ├── values-dev.yaml      # Valeurs pour dev
│       ├── values-prod.yaml     # Valeurs pour production
│       └── templates/
│           ├── deployment.yaml  # Template Deployment
│           ├── service.yaml     # Template Service
│           ├── configmap.yaml   # ConfigMap
│           ├── hpa.yaml        # Horizontal Pod Autoscaler (prod)
│           └── ingress.yaml    # Ingress pour routing
├── scripts/
│   ├── build.sh                # Build l'image Docker
│   ├── deploy.sh               # Déploie avec Helm
│   └── test.sh                 # Teste le déploiement
└── k8s-manifests/              # (Optional) YAML bruts sans Helm
    └── namespace.yaml
```

## Étapes de Réalisation

### 1️⃣ Créer l'Application
```bash
# Créer une simple API Flask
cat > app/app.py << 'EOF'
from flask import Flask, jsonify
import os

app = Flask(__name__)
ENV = os.getenv('ENVIRONMENT', 'development')
VERSION = os.getenv('APP_VERSION', '1.0.0')

@app.route('/')
def home():
    return jsonify({
        'message': 'Hello from Kubernetes!',
        'environment': ENV,
        'version': VERSION
    })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

# Dépendances
echo "Flask==2.3.0" > app/requirements.txt
```

### 2️⃣ Créer le Dockerfile
```bash
cat > app/Dockerfile << 'EOF'
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]
EOF
```

### 3️⃣ Créer le Helm Chart
```bash
# Initialiser la structure
helm create helm/myapp

# Modifier Chart.yaml
# - name: myapp
# - version: 1.0.0
# - appVersion: "1.0"
```

### 4️⃣ Configurer les Templates
**deployment.yaml** : 
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-app
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}
    spec:
      containers:
      - name: app
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        ports:
        - containerPort: {{ .Values.service.port }}
        env:
        - name: ENVIRONMENT
          valueFrom:
            configMapKeyRef:
              name: {{ .Release.Name }}-config
              key: environment
        resources:
          requests:
            memory: "{{ .Values.resources.requests.memory }}"
            cpu: "{{ .Values.resources.requests.cpu }}"
          limits:
            memory: "{{ .Values.resources.limits.memory }}"
            cpu: "{{ .Values.resources.limits.cpu }}"
        livenessProbe:
          httpGet:
            path: /health
            port: {{ .Values.service.port }}
          initialDelaySeconds: 10
```

### 5️⃣ Values par Environnement
**values-dev.yaml** :
```yaml
replicaCount: 1
image:
  tag: "latest"
resources:
  requests:
    memory: "64Mi"
    cpu: "50m"
  limits:
    memory: "128Mi"
    cpu: "100m"
environment: development
```

**values-prod.yaml** :
```yaml
replicaCount: 3
image:
  tag: "latest"
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
environment: production
autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
```

### 6️⃣ Builder l'Image
```bash
cd app
docker build -t myapp:1.0.0 .
# Pour Minikube : 
minikube image load myapp:1.0.0
```

### 7️⃣ Déployer avec Helm
```bash
# Dev
helm install myapp-dev ./helm/myapp -f ./helm/myapp/values-dev.yaml -n dev --create-namespace

# Production
helm install myapp-prod ./helm/myapp -f ./helm/myapp/values-prod.yaml -n production --create-namespace

# Upgrade
helm upgrade myapp-dev ./helm/myapp -f ./helm/myapp/values-dev.yaml

# Vérifier
kubectl get pods -n dev
kubectl get svc -n dev
kubectl port-forward -n dev svc/myapp-dev-app 5000:5000
# Test: curl http://localhost:5000
```

### 8️⃣ Tester le Déploiement
```bash
# Vérifier les pods
kubectl get pods -n dev -o wide

# Logs
kubectl logs -n dev deployment/myapp-dev-app

# Port-forward et tester
kubectl port-forward -n dev svc/myapp-dev-app 5000:5000 &
sleep 2
curl http://localhost:5000/health
```

### 9️⃣ Cleanup
```bash
helm uninstall myapp-dev -n dev
helm uninstall myapp-prod -n production
kubectl delete namespace dev production
```

## Ce qu'on Apprend

### 🎯 Concepts Kubernetes
- **Deployments** : Gestion des réplicas et mises à jour
- **Services** : Exposition des applications
- **ConfigMaps** : Gestion centralisée de la configuration
- **Resources Limits** : Gestion des ressources (CPU/Mémoire)
- **Probes** : Liveness & Readiness checks
- **Namespaces** : Isolation logique des environnements

### 📦 Concepts Helm
- **Chart** : Package Helm avec métadonnées
- **Values** : Paramétrage des déploiements
- **Templates** : Templating avec Golang
- **Releases** : Instance déployée d'un chart
- **Multi-env** : Gérer plusieurs environnements avec des values

### 🛠️ Pratiques DevOps
- Reproducibilité des déploiements
- Version management des applications
- Gestion des secrets et configurations
- Scaling horizontal (HPA)
- Blue-Green deployments possibles

## Commandes Clés

```bash
# Helm
helm repo add stable https://charts.helm.sh/stable
helm search repo
helm lint ./helm/myapp
helm template myapp ./helm/myapp
helm install/upgrade/uninstall

# Kubectl
kubectl get/describe/logs/exec/port-forward
kubectl apply -f manifest.yaml
kubectl rollout status/history
```

## Ressources Complémentaires
- [Kubernetes Docs](https://kubernetes.io/docs/concepts/)
- [Helm Docs](https://helm.sh/docs/)
- [Helm Best Practices](https://helm.sh/docs/chart_best_practices/)
