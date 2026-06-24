# Exemples Pratiques - GitOps Pipeline

## Exemple 1: Test Local de l'Application

### Étape 1: Préparer l'environnement
```bash
cd projects/2026-06-24_github-actions-argocd-gitops/

# Installer les dépendances Python
pip install -r app/requirements.txt

# Lancer l'application localement
python app/server.py
# Accéder à http://localhost:5000
```

### Réponses attendues:
```bash
# Health check
curl http://localhost:5000/health
{
  "environment": "development",
  "status": "healthy",
  "timestamp": "2026-06-24T10:30:45.123456",
  "version": "1.0.0"
}

# Version
curl http://localhost:5000/version
{
  "build_time": "unknown",
  "environment": "development",
  "version": "1.0.0"
}

# Info
curl http://localhost:5000/info
{
  "environment": "development",
  "name": "GitOps Demo App",
  "namespace": "default",
  "pod_name": "unknown",
  "version": "1.0.0"
}
```

---

## Exemple 2: Build Docker Local

### Étape 1: Construire l'image
```bash
docker build -f app/Dockerfile -t gitops-app:dev .
```

### Étape 2: Lancer en container
```bash
docker run -p 5000:5000 \
  -e ENVIRONMENT=production \
  -e APP_VERSION=1.0.0 \
  gitops-app:dev
```

### Étape 3: Tester
```bash
curl http://localhost:5000/health
```

### Exemple avec docker-compose:
```bash
cat > docker-compose.yml <<EOF
version: '3.8'
services:
  app:
    build:
      context: .
      dockerfile: app/Dockerfile
    ports:
      - "5000:5000"
    environment:
      ENVIRONMENT: production
      APP_VERSION: 1.0.0
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      timeout: 3s
      retries: 3
EOF

docker-compose up
docker-compose down
```

---

## Exemple 3: Setup Local avec Minikube

### Étape 1: Démarrer Minikube
```bash
# Démarrer Minikube
minikube start --cpus=4 --memory=4096

# Vérifier le statut
minikube status
minikube ip  # Ex: 192.168.64.3
```

### Étape 2: Charger l'image Docker
```bash
# Construire l'image avec Minikube Docker
eval $(minikube docker-env)
docker build -f app/Dockerfile -t gitops-app:local .

# Ou si vous avez déjà l'image:
docker image save gitops-app:local | (eval $(minikube docker-env) && docker image load)
```

### Étape 3: Installer ArgoCD
```bash
bash argocd/argocd-install.sh
```

### Étape 4: Configuration
```bash
bash argocd/initial-setup.sh
```

### Étape 5: Accéder à l'app
```bash
# Port-forward
kubectl port-forward -n gitops-demo svc/gitops-app 5000:80 &
curl http://localhost:5000/health

# Ou accéder via IP Minikube
kubectl get service -n gitops-demo
# Accéder à http://192.168.64.3:30080
```

---

## Exemple 4: Simuler la Pipeline GitHub Actions

### Scénario: Modifier le code et déployer

#### Étape 1: Modifier l'application
```bash
cat >> app/server.py <<EOF

@app.route('/custom', methods=['GET'])
def custom():
    return jsonify({
        'message': 'Custom endpoint added!',
        'version': VERSION
    }), 200
EOF
```

#### Étape 2: Tester localement
```bash
python app/server.py &
APP_PID=$!
sleep 2
curl http://localhost:5000/custom
kill $APP_PID
```

#### Étape 3: Simuler le build Docker
```bash
# Incrementer la version
cat > app/VERSION <<EOF
1.1.0
EOF

# Build avec un tag de version
docker build -f app/Dockerfile \
  --build-arg VERSION=1.1.0 \
  -t gitops-app:1.1.0 \
  .
```

#### Étape 4: Mettre à jour le manifest
```bash
# Simuler la mise à jour du manifest
sed -i 's|image: .*|image: gitops-app:1.1.0|' k8s/deployment.yaml

# Vérifier
grep "image:" k8s/deployment.yaml
```

#### Étape 5: Vérifier avec ArgoCD
```bash
# Si ArgoCD est installé:
kubectl describe app gitops-demo-app -n argocd

# Voir si synchronisation automatique
kubectl get pods -n gitops-demo
```

---

## Exemple 5: Rollback en cas de problème

### Scénario: Problème détecté, besoin de revenir

```bash
# 1. Voir l'historique Git
git log --oneline -5

# 2. Voir le commit problématique
git show HEAD

# 3. Revenir au commit précédent
git revert HEAD
git push origin main

# 4. ArgoCD détecte automatiquement et redéploie
kubectl get pods -n gitops-demo --watch

# 5. Vérifier que c'est back to normal
curl http://localhost:5000/health
```

---

## Exemple 6: Monitoring avec ArgoCD

### Accéder à l'UI ArgoCD

```bash
# Port-forward
kubectl port-forward -n argocd svc/argocd-server 8080:443 &

# Récupérer le password admin
ARGOCD_PASS=$(kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)
echo "Admin password: $ARGOCD_PASS"
```

### Sur https://localhost:8080:
1. **Username**: admin
2. **Password**: (le mot de passe récupéré)
3. Voir l'application **gitops-demo-app**
4. Voir les manifests synchronisés
5. Voir la santé des pods

---

## Exemple 7: Multi-Replicas et Scaling

### Scénario: L'app a beaucoup de trafic, besoin de scaling

#### Option 1: Via Kubernetes directement (pas recommandé en GitOps!)
```bash
# ⚠️ Ne pas faire en production!
kubectl scale deployment gitops-app -n gitops-demo --replicas=5
```

#### Option 2: Via Git (la bonne façon!)
```bash
# Modifier le manifest
sed -i 's/replicas: 3/replicas: 5/' k8s/deployment.yaml

# Vérifier
grep "replicas:" k8s/deployment.yaml

# Commit et push
git add k8s/deployment.yaml
git commit -m "Scale app to 5 replicas due to high traffic"
git push origin main

# ✅ ArgoCD synchronise automatiquement
kubectl get deployment -n gitops-demo -w
```

---

## Exemple 8: Mise à Jour du Manifests via Kustomize

### Modifier la configuration sans changer YAML

```bash
cd k8s/

# Voir le résultat de kustomize
kubectl kustomize .

# Appliquer avec kustomize (demo)
kubectl apply -k .

# Revert
kubectl delete -k .
```

---

## Exemple 9: Voir les Logs de la Pipeline

### GitHub Actions Logs

Sur GitHub:
1. Aller à **Actions**
2. Sélectionner **Build and Push Docker Image**
3. Voir les étapes:
   - ✅ Checkout
   - ✅ Test
   - ✅ Build Docker
   - ✅ Push to Registry
   - ✅ Update Manifests

### ArgoCD Logs

```bash
# Logs du application controller
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller -f

# Logs du repo server
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-repo-server -f

# Logs de synchronisation
kubectl logs -n gitops-demo -l app=gitops-app -f
```

---

## Exemple 10: Health Check et Readiness

### Vérifier que l'app est en bon état

```bash
# Vérifier les probes
kubectl get pod -n gitops-demo -o wide

# Liveness probe (live?)
curl http://<pod-ip>:5000/health

# Voir les événements
kubectl describe pod <pod-name> -n gitops-demo

# Logs
kubectl logs -n gitops-demo -l app=gitops-app --tail=20
```

---

## Recap: Pipeline Complète en 10 Étapes

```bash
# 1. Cloner le repo
git clone https://github.com/jaouadsiouahe1978/claude-devops-tools
cd claude-devops-tools/projects/2026-06-24_github-actions-argocd-gitops/

# 2. Démarrer Minikube
minikube start

# 3. Lancer quickstart
bash quickstart.sh

# 4. Attendre le déploiement (2 min)
kubectl get pods -n gitops-demo --watch

# 5. Port-forward app
kubectl port-forward -n gitops-demo svc/gitops-app 5000:80 &

# 6. Tester l'app
curl http://localhost:5000/health

# 7. Modifier le code
echo "# New feature" >> app/server.py

# 8. Commit et push
git add app/
git commit -m "Add new feature"
git push origin main

# 9. Regarder les Actions (GitHub)
# https://github.com/jaouadsiouahe1978/claude-devops-tools/actions

# 10. Voir ArgoCD synchroniser
kubectl port-forward -n argocd svc/argocd-server 8080:443 &
# Accéder à https://localhost:8080
```

---

**Créé**: 2026-06-24  
**Niveau**: Débutant à Avancé  
**Tous les exemples sont testables et reproductibles** ✅
