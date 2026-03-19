#!/bin/bash
# Enable Kubernetes Auth in Vault
vault auth enable kubernetes || true

# Configure Vault to talk to K8s API
vault write auth/kubernetes/config \
    kubernetes_host="https://kubernetes.default.svc"

# Create the Application Role
vault write auth/kubernetes/role/app-1-dev-role \
    bound_service_account_names=app-1-dev-sa \
    bound_service_account_namespaces=app-1-dev \
    policies=app-1-dev-policy