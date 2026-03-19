#!/bin/bash
echo "Installing ArgoCD..."
kubectl create namespace argocd || true
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Installing External Secrets Operator..."
kubectl apply -f https://raw.githubusercontent.com/external-secrets/external-secrets/main/deploy/bundle.yaml

echo "Waiting for operators to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=external-secrets -n external-secrets --timeout=120s