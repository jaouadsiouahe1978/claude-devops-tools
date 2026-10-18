#!/bin/bash
# Exemples pratiques de commandes ArgoCD CLI

echo "=== ArgoCD CLI - Exemples pratiques ==="

echo -e "\n### Lister les applications"
# argocd app list
# argocd app list -o json

echo -e "\n### Détails d'une application"
# argocd app get demo-app
# argocd app get demo-app --refresh

echo -e "\n### Voir les ressources"
# argocd app resources demo-app

echo -e "\n### Synchroniser une application"
# argocd app sync demo-app
# argocd app sync demo-app --prune
# argocd app sync demo-app --force
# argocd app sync demo-app --dry-run

echo -e "\n### Attendre la synchronisation"
# argocd app wait demo-app --health
# argocd app wait demo-app --sync

echo -e "\n### Créer une application"
# argocd app create myapp \
#   --repo https://github.com/my-repo \
#   --path . \
#   --dest-server https://kubernetes.default.svc \
#   --dest-namespace default

echo -e "\n### Modifier les paramètres"
# argocd app set demo-app --path new/path
# argocd app set demo-app --sync-policy automated

echo -e "\n### Supprimer une application"
# argocd app delete demo-app
# argocd app delete demo-app --cascade

echo -e "\n### Gestion des repositories"
# argocd repo list
# argocd repo add https://github.com/my-org/repo --username user --password pass

echo -e "\n### Diff et comparaison"
# argocd app diff demo-app
# argocd app diff demo-app --revision HEAD~1

echo ""
echo "Pour plus d'informations: argocd --help"
