# 🚀 End-to-End GitOps Deployment Template

![CI/CD](https://img.shields.io/badge/CI/CD-Bitbucket-blue)
![Kubernetes](https://img.shields.io/badge/Kubernetes-EKS-326CE5)
![GitOps](https://img.shields.io/badge/GitOps-ArgoCD-red)
![Secrets](https://img.shields.io/badge/Secrets-Vault-black)
![Containers](https://img.shields.io/badge/Containers-Docker-2496ED)

A **production-ready GitOps CI/CD template** that automates:

* 🐳 Docker image builds
* 🔐 Secrets management via **HashiCorp Vault**
* ☸ Kubernetes deployments using **ArgoCD**
* ☁ Deployment to **Amazon EKS**
* 🔄 Fully automated **GitOps workflow**

---

# 📊 Architecture Overview

```
Developer Push
      │
      ▼
Bitbucket Pipeline
(Build + Push Docker Image)
      │
      ▼
Amazon ECR
(Container Registry)
      │
      ▼
Git Update (Image Tag)
      │
      ▼
ArgoCD Detects Change
      │
      ▼
Amazon EKS Cluster
      │
      ▼
Application Deployment
```

Secrets Flow:

```
HashiCorp Vault
      │
      ▼
External Secrets Operator
      │
      ▼
Kubernetes Secrets
      │
      ▼
Application Pods
```

---

# 📋 Prerequisites

Before using this template ensure the following infrastructure exists.

---

# ☁ AWS Infrastructure

### Amazon EKS

A running Kubernetes cluster.

---

### Amazon ECR

Create a private repository:

```
dev/app-1
```

---

### IAM OIDC Provider

Configure AWS to trust **Bitbucket OIDC** for passwordless authentication.

---

### IAM Role

The role must allow:

* `ecr:PushImage`
* `ecr:GetAuthorizationToken`

and trust Bitbucket OIDC.

---

# ☸ Kubernetes Operators

## ArgoCD

Install ArgoCD in the cluster to manage GitOps deployments.

---

## External Secrets Operator (ESO)

Syncs secrets from **Vault → Kubernetes**

### Install ESO

<button onclick="navigator.clipboard.writeText('kubectl apply -f https://raw.githubusercontent.com/external-secrets/external-secrets/main/deploy/bundle.yaml')">📋 Copy</button>

```bash
kubectl apply -f https://raw.githubusercontent.com/external-secrets/external-secrets/main/deploy/bundle.yaml
```

---

# 🔐 HashiCorp Vault Setup

Vault must:

* Be **unsealed**
* Be reachable by the **EKS cluster**
* Have **Kubernetes authentication enabled**

---

# 🏗 Repository Structure

```
.
├── .bitbucket-pipelines.yml
│
├── k8s/
│   ├── dev/
│   │   ├── namespace.yaml
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── ingress.yaml
│   │   ├── hpa.yaml
│   │   ├── service-account.yaml
│   │   ├── external-secret.yaml
│   │   └── vault-policy.hcl
│   │
│   └── prod/
│
└── README.md
```

---

# 🚀 Setup Guide

---

# 1️⃣ Vault Secret Management

### Login to Vault

Open the **Vault UI dashboard**.

---

### Store Application Secrets

Navigate to:

```
secret/apps/dev/
```

Create secret:

```
app-1
```

Add environment variables as **key-value pairs**.

Example:

```
DB_HOST=database
DB_PASSWORD=securepassword
API_KEY=123456
```

---

### Create Vault Policy

<button onclick="navigator.clipboard.writeText('vault policy write app-1-dev-policy k8s/dev/vault-policy.hcl')">📋 Copy</button>

```bash
vault policy write app-1-dev-policy k8s/dev/vault-policy.hcl
```

---

### Create Vault Role

<button onclick="navigator.clipboard.writeText('vault write auth/kubernetes/role/app-1-dev-role bound_service_account_names=app-1-dev-sa bound_service_account_namespaces=app-1-dev policies=app-1-dev-policy')">📋 Copy</button>

```bash
vault write auth/kubernetes/role/app-1-dev-role \
  bound_service_account_names=app-1-dev-sa \
  bound_service_account_namespaces=app-1-dev \
  policies=app-1-dev-policy
```

---

# 2️⃣ Bitbucket CI/CD Configuration

Enable **OIDC authentication** in Bitbucket.

---

## Required Pipeline Variables

Update these variables in `bitbucket-pipelines.yml`.

| Variable     | Description        |
| ------------ | ------------------ |
| AWS_ROLE_ARN | IAM Role ARN       |
| ECR_REPO_URL | ECR repository URL |

---

# 🔁 CI/CD Workflow

## Development Workflow

Branch:

```
aws_beta
```

Pipeline automatically:

1️⃣ Builds Docker image
2️⃣ Pushes image to **Amazon ECR**
3️⃣ Updates image tag inside:

```
k8s/dev/deployment.yaml
```

---

## Production Workflow

Branch:

```
main
```

Pipeline:

1️⃣ Requires **Manual Approval**
2️⃣ Builds Docker image
3️⃣ Pushes image to ECR
4️⃣ Updates manifests in

```
k8s/prod/
```

---

# ⚙ ArgoCD GitOps Setup

### Add Git Repository

Navigate to:

```
ArgoCD → Settings → Repositories
```

Add the repository using:

* SSH URL
* Private SSH key

---

### Create ArgoCD Application

| Setting     | Value       |
| ----------- | ----------- |
| Application | `app-1-dev` |
| Project     | `default`   |
| Sync Policy | `Automated` |
| Source Path | `k8s/dev`   |
| Namespace   | `app-1-dev` |

---

# 🔍 Verification

---

## Check Secrets

<button onclick="navigator.clipboard.writeText('kubectl get secret -n app-1-dev')">📋 Copy</button>

```bash
kubectl get secret -n app-1-dev
```

---

## Check Pods

<button onclick="navigator.clipboard.writeText('kubectl get pods -n app-1-dev')">📋 Copy</button>

```bash
kubectl get pods -n app-1-dev
```

---

# 🌐 Access the Application

Example URL:

```
https://dev-app-1.com
```

---

# 📈 Scaling & Resource Management

## Horizontal Pod Autoscaler

* Minimum replicas: **1**
* Maximum replicas: **3**
* CPU threshold: **70%**

---

## Resource Limits

| Resource | Request | Limit |
| -------- | ------- | ----- |
| CPU      | 100m    | 200m  |
| Memory   | 250Mi   | 350Mi |

---

# 🔒 Security

Security best practices included:

* 🔐 Vault-managed secrets
* 🔑 OIDC authentication
* 📜 IAM least-privilege roles
* 🔒 TLS via **cert-manager**
* 📡 Automatic Let's Encrypt certificates

---

# 🧠 Benefits of This Template

✅ Fully automated **GitOps deployment**
✅ Secure **Vault-based secrets**
✅ Passwordless **OIDC authentication**
✅ **Production-ready Kubernetes architecture**
✅ Easy environment promotion **dev → prod**

---
