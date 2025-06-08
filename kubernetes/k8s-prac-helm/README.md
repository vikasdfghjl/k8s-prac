# K8s-Prac Helm Chart

A production-ready Helm chart for deploying a Node.js backend application with MongoDB on Kubernetes.

## 📋 Table of Contents
- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Deployment Environments](#deployment-environments)
- [Monitoring & Observability](#monitoring--observability)
- [Security](#security)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

This Helm chart deploys:
- **Backend API**: Node.js/TypeScript application with Express.js
- **MongoDB**: Database with persistent storage
- **Secrets Management**: Kubernetes secrets for sensitive data
- **Monitoring**: Prometheus metrics integration
- **Auto-scaling**: Horizontal Pod Autoscaler (HPA) support
- **Ingress**: Optional ingress controller support

### Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Ingress     │    │   Backend API   │    │    MongoDB      │
│   (Optional)    │───▶│   (NodePort/    │───▶│   (ClusterIP)   │
│                 │    │   ClusterIP)    │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │   Prometheus    │
                       │    Metrics      │
                       └─────────────────┘
```

## ✅ Prerequisites

- Kubernetes cluster (v1.19+)
- Helm 3.x
- kubectl configured
- Storage class available for PersistentVolumes

### Verify Prerequisites
```powershell
# Check Kubernetes connection
kubectl cluster-info

# Check Helm version
helm version

# Check available storage classes
kubectl get storageclass
```

## 🚀 Quick Start

### 1. Clone and Navigate
```powershell
cd c:\Users\vikas\k8s-prac\kubernetes\k8s-prac-helm
```

### 2. Validate the Chart
```powershell
# Lint the chart
helm lint .

# Dry run to see what will be deployed
helm template my-app . --values values-dev.yaml
```

### 3. Deploy to Development
```powershell
# Install with development values
helm install k8s-prac-dev . -f values-dev.yaml

# Check deployment status
kubectl get all -l app.kubernetes.io/instance=k8s-prac-dev
```

### 4. Access the Application
```powershell
# Get the NodePort
$NODE_PORT = kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services k8s-prac-dev
$NODE_IP = kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}"
Write-Host "Application URL: http://$NODE_IP`:$NODE_PORT"
```

## ⚙️ Configuration

### Core Values

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of backend replicas | `1` |
| `image.repository` | Backend image repository | `vikasdfghjl/k8s-prac` |
| `image.tag` | Backend image tag | `latest` |
| `service.type` | Kubernetes service type | `NodePort` |
| `service.port` | Service port | `5000` |

### MongoDB Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `mongodb.enabled` | Enable MongoDB deployment | `true` |
| `mongodb.image.repository` | MongoDB image | `mongo` |
| `mongodb.image.tag` | MongoDB version | `8.0` |
| `mongodb.persistence.size` | Storage size | `1Gi` |
| `mongodb.auth.rootUsername` | MongoDB root username | `vikas` |
| `mongodb.auth.rootPassword` | MongoDB root password | `singh123` |

### Resource Configuration

```yaml
resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi
```

### Auto-scaling Configuration

```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80
```

## 🌍 Deployment Environments

### Development Environment
```powershell
helm install k8s-prac-dev . -f values-dev.yaml
```
**Features:**
- 1 replica
- NodePort service
- Debug logging
- Small resource limits
- 500Mi MongoDB storage

### Staging Environment
```powershell
helm install k8s-prac-staging . -f values-staging.yaml
```
**Features:**
- 2 replicas
- ClusterIP with Ingress
- Auto-scaling enabled (2-5 replicas)
- Medium resource allocation
- 2Gi MongoDB storage

### Production Environment
```powershell
helm install k8s-prac-prod . -f values-prod.yaml
```
**Features:**
- 3 replicas
- ClusterIP with TLS Ingress
- Auto-scaling enabled (3-10 replicas)
- High resource allocation
- 10Gi MongoDB storage
- Security contexts enabled
- Node selectors and tolerations

## 📊 Monitoring & Observability

### Prometheus Integration
The chart includes built-in Prometheus metrics:

```yaml
podAnnotations:
  prometheus.io/scrape: "true"
  prometheus.io/path: "/metrics"
  prometheus.io/port: "5000"
```

### Health Checks
```yaml
livenessProbe:
  httpGet:
    path: /
    port: 5000
    
readinessProbe:
  httpGet:
    path: /
    port: 5000
```

### Monitoring Commands
```powershell
# View metrics
kubectl exec -it deployment/k8s-prac-dev -- curl localhost:5000/metrics

# Monitor pod resources
kubectl top pods -l app.kubernetes.io/instance=k8s-prac-dev

# View HPA status
kubectl get hpa
```

## 🔐 Security

### Secrets Management
```yaml
secrets:
  enabled: true
  data:
    MONGO_URI: "mongodb://..."
    JWT_SECRET: "your-jwt-secret"
```

### Security Contexts (Production)
```yaml
podSecurityContext:
  fsGroup: 2000
  runAsNonRoot: true
  runAsUser: 1000

securityContext:
  capabilities:
    drop: [ALL]
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000
```

### Best Practices
- ✅ Secrets stored in Kubernetes Secrets
- ✅ Non-root user execution
- ✅ Read-only root filesystem (production)
- ✅ Dropped Linux capabilities
- ✅ Resource limits enforced

## 🛠️ Troubleshooting

### Common Issues

#### 1. Pods Not Starting
```powershell
# Check pod status
kubectl get pods -l app.kubernetes.io/instance=k8s-prac-dev

# Describe pod for events
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name> -f
```

#### 2. Database Connection Issues
```powershell
# Test MongoDB connectivity
kubectl exec -it deployment/k8s-prac-dev -- curl k8s-prac-dev-mongodb:27017

# Check MongoDB logs
kubectl logs deployment/k8s-prac-dev-mongodb

# Verify secrets
kubectl get secret k8s-prac-dev-secrets -o yaml
```

#### 3. Service Access Issues
```powershell
# Check service endpoints
kubectl get endpoints

# Test service from inside cluster
kubectl run test-pod --image=curlimages/curl -it --rm -- /bin/sh
# Inside pod: curl k8s-prac-dev:5000
```

#### 4. Storage Issues
```powershell
# Check PVC status
kubectl get pvc

# Check available storage
kubectl get pv

# Describe storage issues
kubectl describe pvc k8s-prac-dev-mongo-pvc
```

### Debugging Commands
```powershell
# Get all resources for release
kubectl get all -l app.kubernetes.io/instance=k8s-prac-dev

# Check Helm release status
helm status k8s-prac-dev

# View Helm release history
helm history k8s-prac-dev

# Debug Helm template rendering
helm template k8s-prac-dev . -f values-dev.yaml --debug
```

## 📚 Advanced Operations

### Scaling
```powershell
# Manual scaling
kubectl scale deployment k8s-prac-dev --replicas=3

# Update via Helm
helm upgrade k8s-prac-dev . -f values-dev.yaml --set replicaCount=3
```

### Updates and Rollbacks
```powershell
# Update image tag
helm upgrade k8s-prac-dev . -f values-dev.yaml --set image.tag=v1.1.0

# Rollback to previous version
helm rollback k8s-prac-dev

# Rollback to specific revision
helm rollback k8s-prac-dev 2
```

### Backup and Restore
```powershell
# Backup MongoDB data
kubectl exec deployment/k8s-prac-dev-mongodb -- mongodump --uri="mongodb://vikas:singh123@localhost:27017/totodo-dev?authSource=admin" --out=/tmp/backup

# Copy backup from pod
kubectl cp k8s-prac-dev-mongodb-xxx:/tmp/backup ./mongodb-backup
```

## 🧪 Testing

### Chart Testing
```powershell
# Run Helm tests
helm test k8s-prac-dev

# Validate chart
helm lint .

# Check template rendering
helm template . --values values-dev.yaml
```

### Application Testing
```powershell
# Health check
kubectl exec -it deployment/k8s-prac-dev -- curl localhost:5000/

# API testing
$POD_NAME = kubectl get pods -l app.kubernetes.io/instance=k8s-prac-dev -o jsonpath="{.items[0].metadata.name}"
kubectl port-forward $POD_NAME 8080:5000
# Test at http://localhost:8080
```

## 📝 Customization

### Custom Values Example
```yaml
# custom-values.yaml
replicaCount: 5

image:
  tag: "v2.0.0"

resources:
  limits:
    cpu: 2000m
    memory: 2Gi
  requests:
    cpu: 1000m
    memory: 1Gi

mongodb:
  persistence:
    size: 20Gi
  resources:
    limits:
      cpu: 1000m
      memory: 2Gi

autoscaling:
  enabled: true
  minReplicas: 5
  maxReplicas: 20
  targetCPUUtilizationPercentage: 60
```

Deploy with custom values:
```powershell
helm install k8s-prac-custom . -f custom-values.yaml
```

---

## 📞 Support

For issues and questions:
1. Check the [troubleshooting section](#troubleshooting)
2. Review Kubernetes events: `kubectl get events`
3. Check application logs: `kubectl logs -l app.kubernetes.io/instance=<release-name>`
4. Validate Helm chart: `helm lint .`

**Happy Kubernetes deployment! 🚀**
