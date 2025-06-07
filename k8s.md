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

## Notes
- Update your `MONGO_URI` in the secret if you change MongoDB credentials or service name.
- Check logs with `kubectl logs -l app=backend` or `kubectl logs -l app=mongodb` for troubleshooting.
- You can access the backend at `http://<minikube-ip>:<nodeport>`.
