# Kubernetes Setup Guide - Interview Ready

*A comprehensive guide to understand and explain your Kubernetes architecture like a pro*

---

## 📋 Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Core Components](#core-components)
3. [Deployment Strategies](#deployment-strategies)
4. [Security Implementation](#security-implementation)
5. [Monitoring & Observability](#monitoring--observability)
6. [Interview Questions & Answers](#interview-questions--answers)
7. [Troubleshooting Guide](#troubleshooting-guide)

---

## 🏗️ Architecture Overview

### What We've Built
You have a **3-tier microservices architecture** deployed on Kubernetes:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend API   │    │   MongoDB       │
│   (External)    │───▶│   Node.js/TS    │───▶│   Database      │
│                 │    │   Port: 5000    │    │   Port: 27017   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

**Key Statistics:**
- **Backend**: Node.js with TypeScript, Express.js
- **Database**: MongoDB with persistent storage
- **Deployment**: Kubernetes with both raw manifests and Helm charts
- **Security**: Kubernetes Secrets + Sealed Secrets
- **Monitoring**: Prometheus metrics integration

---

## 🔧 Core Components

### 1. Backend Application (`k8s-backend.yaml`)

**Deployment Specs:**
```yaml
- Replicas: 1 (can be scaled)
- Image: vikasdfghjl/k8s-prac:latest
- Container Port: 5000
- Service Type: NodePort
```

**Why This Matters:**
- **NodePort**: Allows external access (port range 30000-32767)
- **Single Replica**: Good for development, scale for production
- **Container Port**: Application listens on 5000 internally

**Interview Answer:** *"We're using a Deployment with NodePort service for our backend. This gives us the flexibility to scale horizontally and provides external access without needing a LoadBalancer in our local environment."*

### 2. MongoDB Database (`k8s-mongo.yaml`)

**Key Features:**
- **Persistent Volume Claim**: 1Gi storage for data persistence
- **StatefulSet Pattern**: Uses Deployment but with persistent storage
- **Root Credentials**: Username: `vikas`, Password: `singh123`

**Storage Strategy:**
```yaml
PVC → 1Gi ReadWriteOnce → /data/db mount
```

**Interview Answer:** *"We implement data persistence using PersistentVolumeClaims to ensure data survives pod restarts. The MongoDB deployment uses a PVC mounted to /data/db with 1Gi of storage."*

### 3. Secrets Management (`k8s-secret.yaml`)

**Security Implementation:**
```yaml
- MONGO_URI: base64 encoded connection string
- JWT_SECRET: base64 encoded secret key
```

**Sealed Secrets Enhancement:**
Your setup includes **Bitnami Sealed Secrets** (`my-sealed-secret.yaml`) for enhanced security.

**Interview Answer:** *"We implement a two-layer security approach: Kubernetes native Secrets for development and Sealed Secrets for production. Sealed Secrets encrypt secrets at rest and can be safely stored in Git."*

---

## 🚀 Deployment Strategies

### Strategy 1: Raw Kubernetes Manifests

**Deployment Order:**
```bash
# 1. Apply secrets first
kubectl apply -f k8s-secret.yaml

# 2. Deploy database
kubectl apply -f k8s-mongo.yaml

# 3. Deploy backend (depends on MongoDB service)
kubectl apply -f k8s-backend.yaml
```

**Pros:**
- ✅ Direct control over resources
- ✅ Easy to understand and modify
- ✅ No additional tooling required

**Cons:**
- ❌ Manual dependency management
- ❌ No templating for different environments
- ❌ Harder to manage complex configurations

### Strategy 2: Helm Charts

**Your Helm Setup:**
```yaml
Chart: k8s-prac (v0.1.0)
App Version: 1.16.0
Type: Application Chart
```

**Deployment Command:**
```bash
helm install my-app ./k8s-prac-helm
```

**Pros:**
- ✅ Template-based configuration
- ✅ Easy environment management
- ✅ Version control and rollbacks
- ✅ Built-in dependency management

**Interview Answer:** *"We use Helm for production deployments because it provides templating, versioning, and environment-specific configurations. Raw manifests are great for development and learning."*

---

## 🔐 Security Implementation

### 1. Kubernetes Secrets
```yaml
# Base64 encoded values
MONGO_URI: bW9uZ29kYjovL3Zpa2FzOnNpbmdoMTIzQG1vbmdvZGI6MjcwMTcvdG90b2RvP2F1dGhTb3VyY2U9YWRtaW4=
JWT_SECRET: YWJjZGVmZzEyMzQ1Njc=
```

### 2. Sealed Secrets
- **Controller**: Bitnami Sealed Secrets
- **Encryption**: RSA encryption for secrets
- **Git-Safe**: Encrypted secrets can be committed to version control

### 3. Environment Variable Injection
```yaml
env:
  - name: MONGO_URI
    valueFrom:
      secretKeyRef:
        name: backend-secrets
        key: MONGO_URI
```

**Security Best Practices Implemented:**
- ✅ No hardcoded secrets in manifests
- ✅ Base64 encoding for basic obfuscation
- ✅ Sealed Secrets for production-grade encryption
- ✅ Proper secret reference in deployments

**Interview Answer:** *"Our security strategy uses layered secret management. We inject environment variables from Kubernetes Secrets, avoiding hardcoded values. For production, we implement Sealed Secrets which encrypt data and integrate with GitOps workflows."*

---

## 📊 Monitoring & Observability

### Prometheus Integration

**Your Backend Metrics Setup:**
```typescript
// Prometheus client integration
import client from 'prom-client';
const collectDefaultMetrics = client.collectDefaultMetrics;
collectDefaultMetrics();
```

**Pod Annotations for Prometheus:**
```yaml
podAnnotations:
  prometheus.io/scrape: "true"
  prometheus.io/path: "/metrics"
  prometheus.io/port: "5000"
```

**What This Provides:**
- 📈 Application metrics collection
- 🎯 Custom business metrics capability
- 🔍 Performance monitoring
- 🚨 Alerting foundation

**Interview Answer:** *"We've integrated Prometheus client library in our Node.js application to expose metrics on /metrics endpoint. Pod annotations tell Prometheus to scrape metrics from port 5000, enabling comprehensive monitoring."*

---

## 🎯 Interview Questions & Answers

### Q1: "Explain your Kubernetes architecture"
**Answer:** *"We run a 3-tier microservices architecture on Kubernetes. The backend is a Node.js application deployed as a Kubernetes Deployment with 1 replica, exposed via NodePort service. MongoDB runs as a separate deployment with persistent storage using PVC. Both communicate securely using Kubernetes native DNS resolution."*

### Q2: "How do you handle persistent data?"
**Answer:** *"We use PersistentVolumeClaims for MongoDB data persistence. The PVC requests 1Gi of ReadWriteOnce storage and mounts to /data/db in the MongoDB container. This ensures data survives pod restarts, crashes, and rescheduling."*

### Q3: "How do you manage secrets?"
**Answer:** *"We implement a multi-layer approach: Kubernetes Secrets for basic use cases and Sealed Secrets for production. Secrets are injected as environment variables using secretKeyRef, avoiding hardcoded values. Sealed Secrets provide GitOps-friendly encrypted secret management."*

### Q4: "How would you scale this application?"
**Answer:** *"For horizontal scaling, I'd increase replicas in the backend deployment and add a LoadBalancer service. For the database, I'd implement MongoDB replica sets or consider managed solutions like MongoDB Atlas. I'd also add resource limits, HPA (Horizontal Pod Autoscaler), and consider implementing caching layers."*

### Q5: "What monitoring is in place?"
**Answer:** *"We've integrated Prometheus metrics collection with proper pod annotations for scraping. The backend exposes default Node.js metrics on /metrics endpoint. For production, I'd add Grafana dashboards, alerting rules, and application-specific business metrics."*

### Q6: "How do you handle configuration for different environments?"
**Answer:** *"We use Helm charts with values.yaml for environment-specific configurations. Different environments (dev/staging/prod) have separate values files. This allows us to maintain the same template while varying configurations like image tags, resources, and environment variables."*

---

## 🛠️ Troubleshooting Guide

### Common Issues & Solutions

#### 1. Pod Not Starting
```bash
# Check pod status
kubectl get pods

# Describe pod for events
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>
```

#### 2. Service Connection Issues
```bash
# Test service connectivity
kubectl exec -it <backend-pod> -- curl mongodb:27017

# Check service endpoints
kubectl get endpoints

# Verify DNS resolution
kubectl exec -it <pod> -- nslookup mongodb
```

#### 3. Secrets Not Loading
```bash
# Verify secret exists
kubectl get secrets

# Check secret data
kubectl describe secret backend-secrets

# Verify environment variables in pod
kubectl exec -it <pod> -- env | grep MONGO
```

#### 4. Storage Issues
```bash
# Check PVC status
kubectl get pvc

# Describe PVC for events
kubectl describe pvc mongo-pvc

# Check available storage
kubectl get pv
```

---

## 📚 Next Steps for Production

### Immediate Improvements:
1. **Add Resource Limits**: Define CPU/memory limits and requests
2. **Health Checks**: Implement readiness and liveness probes
3. **Ingress Controller**: Replace NodePort with Ingress for better routing
4. **Namespace Isolation**: Use dedicated namespaces for environments

### Advanced Enhancements:
1. **Service Mesh**: Consider Istio for advanced networking
2. **GitOps**: Implement ArgoCD or Flux for automated deployments
3. **Security Scanning**: Add tools like Falco for runtime security
4. **Backup Strategy**: Implement MongoDB backup automation

---

## 🎓 Key Takeaways for Interviews

1. **You understand multi-tier architecture** on Kubernetes
2. **You can explain persistent storage** and why it matters
3. **You implement proper secret management** with multiple approaches
4. **You have monitoring and observability** foundations
5. **You use both raw manifests and Helm** showing flexibility
6. **You can troubleshoot common issues** systematically

**Final Interview Tip:** Always relate your technical choices back to business value. Explain not just *what* you built, but *why* you made those architectural decisions.

---

*This guide covers your complete Kubernetes setup. Practice explaining each component and be ready to dive deeper into any section during interviews!*
