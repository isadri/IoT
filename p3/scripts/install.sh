#!/bin/bash
set -e

# SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo apt update
sudo apt install -y curl

# Docker
if ! command -v docker &>/dev/null; then
  curl -fsSL https://get.docker.com | sh
  systemctl enable docker
  systemctl start docker
fi

# kubectl
if ! command -v kubectl &>/dev/null; then
  curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  mv kubectl /usr/local/bin/
fi

# k3d
if ! command -v k3d &>/dev/null; then
  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi

# Create cluster with port mapping: localhost:8888 -> node:30888
k3d cluster create iot --port "8888:30888@loadbalancer"

until kubectl get nodes &>/dev/null; do
  sleep 2
done

# Namespaces
kubectl create namespace argocd
kubectl create namespace dev

# Install Argo CD
# kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for Argo CD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Deploy Argo CD Application
# kubectl apply -f "$SCRIPT_DIR/../confs/argocd-app.yaml"
kubectl apply -f "/home/vagrant/confs/argocd-app.yaml"

echo ""
echo "=== Argo CD admin password ==="
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d
echo ""
echo ""
echo "Access UI: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "Test app:  curl http://localhost:8888/"
