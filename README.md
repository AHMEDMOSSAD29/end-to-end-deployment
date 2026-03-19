# 🚀 GitOps Deployment Template

![CI/CD](https://img.shields.io/badge/CI/CD-Multi--Platform-blue)
![Kubernetes](https://img.shields.io/badge/Kubernetes-EKS-326CE5)
![GitOps](https://img.shields.io/badge/GitOps-ArgoCD-red)
![Secrets](https://img.shields.io/badge/Secrets-Vault-black)
![Containers](https://img.shields.io/badge/Containers-Docker-2496ED)

A **production-ready, platform-agnostic GitOps CI/CD template** that automates:

* 🐳 **Docker image builds** 
* 🔐 **Secrets management** via **HashiCorp Vault**
* ☸ **Kubernetes deployments** using **ArgoCD**
* ☁ **Multi-Cloud CI/CD** support for **GitHub Actions**, **GitLab CI**, and **Bitbucket Pipelines**
* 🔄 Fully automated **GitOps workflow** targeting **Amazon EKS**

---

# 📊 Architecture Overview

```
Developer Push (GitHub/GitLab/Bitbucket)
            │
            ▼
Pipeline (Actions / CI / Pipelines)
            │
            ▼
Build & Push Docker Image ─────────────▶ Amazon ECR
            │
            ▼
Update Git Manifests (k8s/deployment.yaml)
            │
            ▼
ArgoCD Detects Change ────────────────▶ Syncs to Amazon EKS Cluster
```

---

# 📋 Prerequisites & Setup Guide

Ensure the following infrastructure exists before deploying. You can use the automation scripts in the `/setup` folder.

## ☁️ AWS Infrastructure

### 1. Amazon EKS

* **Requirement:** A running EKS cluster (v1.27+)
* **Guide:** https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html

### 2. Amazon ECR

* **Requirement:** Private repository (e.g., `dev/app-1`)
* **Command:**

```bash
aws ecr create-repository --repository-name dev/app-1
```

### 3. IAM OIDC Provider

Configure AWS to trust your CI/CD provider:

* GitHub: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services
* GitLab: https://docs.gitlab.com/ee/ci/cloud_services/aws/
* Bitbucket: https://support.atlassian.com/bitbucket-cloud/docs/deploy-to-aws-using-oidc/

---

## ☸️ Kubernetes Operators

### ArgoCD

* **Purpose:** GitOps deployment controller
* **Install:**

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### External Secrets Operator (ESO)

* **Purpose:** Sync secrets from Vault → Kubernetes
* **Install:**

```bash
kubectl apply -f https://raw.githubusercontent.com/external-secrets/external-secrets/main/deploy/bundle.yaml
```

---

## 🔐 HashiCorp Vault Setup

Vault must:

* Be **unsealed**
* Be reachable from the EKS cluster
* Have **Kubernetes auth enabled**

Guide: https://developer.hashicorp.com/vault/docs/auth/kubernetes

---

# 🏗 Repository Structure

```
.
├── .bitbucket-pipelines.yml
├── .github/workflows/
├── .gitlab-ci.yml
├── Dockerfile
├── setup/
│   ├── aws-iam-setup.sh
│   ├── vault-k8s-auth.sh
│   └── install-operators.sh
├── k8s/
│   ├── dev/
│   │   ├── deployment.yaml
│   │   ├── ingress.yaml
│   │   └── vault-policy.hcl
│   └── prod/
└── README.md
```

---

# 🚀 Setup Guide

## 1️⃣ Vault Secret Management

### Store Secrets

* Path: `secret/apps/dev/`
* Create secret: `app-1`

### Apply Policy

```bash
vault policy write app-1-dev-policy k8s/dev/vault-policy.hcl
```

### Create Role

```bash
vault write auth/kubernetes/role/app-1-dev-role \
  bound_service_account_names=app-1-dev-sa \
  bound_service_account_namespaces=app-1-dev \
  policies=app-1-dev-policy
```

---

## 2️⃣ Multi-Platform CI/CD Configuration

Set these variables in your CI/CD platform:

| Variable     | Description                    |
| ------------ | ------------------------------ |
| AWS_ROLE_ARN | IAM Role ARN for ECR access    |
| ECR_REPO_URL | Your Amazon ECR repository URL |

---

## ⚙️ ArgoCD GitOps Setup

### Add Repository

* Go to **ArgoCD → Settings → Repositories**
* Add your Git repository

### Create Application

* **Source Path:** `k8s/dev`
* **Namespace:** `app-1-dev`

---

# 🔍 Verification & Access

### Check Secrets

```bash
kubectl get secret -n app-1-dev
```

### Check Pods

```bash
kubectl get pods -n app-1-dev
```

### Access Application

* Open URL from `ingress.yaml`
  Example: `https://dev-app-1.com`

---

# 🔒 Security & Scaling

* **Scaling:** HPA enabled (1–3 replicas, CPU-based 70%)
* **Resources:** Optimized requests & limits
* **TLS:** Automated via **cert-manager + Let's Encrypt**

---

# ✅ Summary

This template gives you:

* Fully automated **GitOps workflow**
* Secure **Vault-based secrets**
* Multi-platform CI/CD compatibility
* Production-ready Kubernetes deployment

---

💡 *Ready to clone, customize, and deploy your app in minutes.*
