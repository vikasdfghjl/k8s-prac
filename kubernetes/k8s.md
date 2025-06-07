# Deploying Backend and MongoDB on Kubernetes (Minikube)

This guide explains how to deploy your Node.js backend and MongoDB using Kubernetes manifests on Minikube.

---

## Prerequisites
- [Minikube](https://minikube.sigs.k8s.io/docs/) installed and running
- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed
- Docker installed (for building images)

---

## 1. Start Minikube
```powershell
minikube start
```

---

## 2. Build and Push Backend Docker Image
If using Docker Hub (recommended):
```powershell
cd backend
docker build -t <your-dockerhub-username>/k8s-prac:latest .
docker push <your-dockerhub-username>/k8s-prac:latest
cd ..
```
Update the image name in `k8s-backend.yaml` to match your Docker Hub repository.

---

## 3. Create Kubernetes Secrets
Encode your secrets in base64 and update `k8s-secret.yaml` if needed. Then apply:
```powershell
kubectl apply -f k8s-secret.yaml
```

---

## 4. Deploy MongoDB
```powershell
kubectl apply -f k8s-mongo.yaml
```

---

## 5. Deploy Backend
```powershell
kubectl apply -f k8s-backend.yaml
```

---

## 6. Check Pod and Service Status
```powershell
kubectl get pods
kubectl get svc
```

---

## 7. Access the Backend
Get the NodePort for the backend service:
```powershell
kubectl get svc backend
```
Or let Minikube open it for you:
```powershell
minikube service backend
```

---

## 8. Clean Up
To delete all resources:
```powershell
kubectl delete -f k8s-backend.yaml
kubectl delete -f k8s-mongo.yaml
kubectl delete -f k8s-secret.yaml
```
To delete the entire Minikube cluster:
```powershell
minikube delete
```

---

## Deploying with Helm

### 1. Install Helm (if not already installed)
See: https://helm.sh/docs/intro/install/

### 2. Create a Helm Chart
```powershell
helm create k8s-prac
```

### 3. Update values.yaml
- Set your image repository and tag:
  - `repository: <your-dockerhub-username>/k8s-prac`
  - `tag: "latest"`
- Set `service.type` to `NodePort` and `service.port` to `5000`.
- Set liveness and readiness probes to port `5000`.

### 4. Install the Helm Chart
```powershell
helm install <release-name> ./k8s-prac
# Example:
helm install my-backend ./k8s-prac
```

### 5. Upgrade the Helm Release (if you make changes)
```powershell
helm upgrade my-backend ./k8s-prac
```

### 6. Uninstall the Helm Release
```powershell
helm uninstall my-backend
```

### 7. Access the Application
```powershell
minikube service my-backend-k8s-prac
```

- Or get the NodePort and Minikube IP manually:
```powershell
$NODE_PORT = kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services my-backend-k8s-prac
$NODE_IP = minikube ip
echo "http://$NODE_IP`:$NODE_PORT"
```

---

## Deploying with ArgoCD (GitOps)

### 1. Install ArgoCD
- Follow the official documentation: https://argo-cd.readthedocs.io/en/stable/getting_started/
- This covers installation on Kubernetes, accessing the ArgoCD UI, and logging in.

### 2. Using Sealed Secrets for Secure Secret Management
- Use [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets) to safely store encrypted secrets in your Git repository.
- Example: Your `my-sealed-secret.yaml` file in the `kubernetes/` directory is a SealedSecret.
- To create a sealed secret:
  1. Install kubeseal and the Sealed Secrets controller (see the [official docs](https://github.com/bitnami-labs/sealed-secrets#installation)).
  2. Create a Kubernetes Secret as usual.
  3. Run `kubeseal --format yaml < my-secret.yaml > my-sealed-secret.yaml` to generate the sealed secret.
  4. Commit `my-sealed-secret.yaml` to your repo (never commit raw secrets).
  5. ArgoCD will apply the SealedSecret, and the controller will decrypt it into a real Secret in your cluster.

### 3. Creating an ArgoCD Application for Your Project
- Example manifest (`kubernetes/argocd-app.yaml`):

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: k8s-prac
spec:
  destination:
    namespace: default
    server: https://kubernetes.default.svc
  project: default
  source:
    repoURL: https://github.com/vikasdfghjl/k8s-prac
    targetRevision: HEAD
    path: kubernetes/k8s-prac
    helm:
      valueFiles:
        - values.yaml
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions: []
```

- Apply this manifest to ArgoCD (via UI or CLI) to enable GitOps deployment of your Helm chart and sealed secrets.

---

## Notes
- Update your `MONGO_URI` in the secret if you change MongoDB credentials or service name.
- Check logs with `kubectl logs -l app=backend` or `kubectl logs -l app=mongodb` for troubleshooting.
- You can access the backend at `http://<minikube-ip>:<nodeport>`.
