# Quick Deployment Guide 🚀

## 📋 Prerequisites Checklist
- [ ] Minikube/Kubernetes cluster running
- [ ] Helm 3.x installed
- [ ] kubectl configured
- [ ] Docker image built and pushed

## 🎯 Quick Commands

### 1. Development Deployment
```powershell
# Navigate to chart directory
cd c:\Users\vikas\k8s-prac\kubernetes\k8s-prac-helm

# Deploy to development
.\deploy.ps1 -Environment dev -Action install

# Or manually:
helm install k8s-prac-dev . -f values-dev.yaml
```

### 2. Access Application
```powershell
# Get NodePort URL
$NODE_PORT = kubectl get svc k8s-prac-dev -o jsonpath="{.spec.ports[0].nodePort}"
$NODE_IP = kubectl get nodes -o jsonpath="{.items[0].status.addresses[0].address}"
Write-Host "Application URL: http://$NODE_IP`:$NODE_PORT"

# Or use port-forward
kubectl port-forward svc/k8s-prac-dev 8080:5000
# Access at http://localhost:8080
```

### 3. Monitor Deployment
```powershell
# Check all resources
kubectl get all -l app.kubernetes.io/instance=k8s-prac-dev

# Watch pods
kubectl get pods -l app.kubernetes.io/instance=k8s-prac-dev -w

# Check logs
kubectl logs -l app.kubernetes.io/instance=k8s-prac-dev -f
```

### 4. Environment Deployments

**Staging:**
```powershell
.\deploy.ps1 -Environment staging -Action install
```

**Production:**
```powershell
.\deploy.ps1 -Environment prod -Action install
```

### 5. Common Operations

**Upgrade:**
```powershell
.\deploy.ps1 -Environment dev -Action upgrade
```

**Uninstall:**
```powershell
.\deploy.ps1 -Environment dev -Action uninstall
```

**Dry Run (test before deploy):**
```powershell
.\deploy.ps1 -Environment dev -Action install -DryRun
```

**Status Check:**
```powershell
.\deploy.ps1 -Environment dev -Action status
```

## 🔧 Troubleshooting

**Pods not starting:**
```powershell
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

**Database connection issues:**
```powershell
kubectl exec -it deployment/k8s-prac-dev-mongodb -- mongosh --username vikas
```

**Service not accessible:**
```powershell
kubectl get svc
kubectl describe svc k8s-prac-dev
```

## 📊 Production Checklist
- [ ] Use external secret management (not built-in secrets)
- [ ] Configure proper resource limits
- [ ] Set up monitoring and alerting
- [ ] Configure backup for MongoDB
- [ ] Use ingress with TLS
- [ ] Implement network policies
- [ ] Set up horizontal pod autoscaling

## 🎉 Success!
Your Kubernetes application should now be running successfully with:
- ✅ Backend API on port 5000
- ✅ MongoDB with persistent storage
- ✅ Prometheus metrics enabled
- ✅ Environment-specific configurations
- ✅ Auto-scaling capabilities (staging/prod)
