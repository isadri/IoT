##!/bin/bash

#set -e

#script_dir="$(cd "$(dirname "${bash_source[0]}")" && pwd)"

## -------------------------
## docker
## -------------------------

#if ! command -v docker &>/dev/null; then
#    curl -fssl https://get.docker.com | sh
#    systemctl enable docker
#    systemctl start docker
#fi

#usermod -ag docker vagrant
#newgrp docker


## -------------------------
## kubectl
## -------------------------

#if ! command -v kubectl &>/dev/null; then
#    curl -lo "https://dl.k8s.io/release/$(curl -ls https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
#    chmod +x kubectl
#    mv kubectl /usr/local/bin/kubectl
#fi


## -------------------------
## k3d
## -------------------------

#if ! command -v k3d &>/dev/null; then
#    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
#fi


## -------------------------
## create k3d cluster
## -------------------------

#if ! k3d cluster get iot &>/dev/null; then
#    k3d cluster create iot \
#        --port "8888:30888@loadbalancer"
#fi


#sudo echo "kubeconfig=$(k3d kubeconfig write iot)" > /etc/environment

## -------------------------
## wait for kubernetes
## -------------------------

#echo "waiting for kubernetes..."

#until kubectl get nodes &>/dev/null; do
#    sleep 2
#done

#echo "kubernetes is ready."


## -------------------------
## namespaces
## -------------------------

#kubectl create namespace argocd \
#    --dry-run=client -o yaml | kubectl apply -f -

#kubectl create namespace dev \
#    --dry-run=client -o yaml | kubectl apply -f -


## -------------------------
## argo cd
## -------------------------

#echo "installing argo cd..."

#kubectl apply \
#    -n argocd \
#    --server-side \
#    --force-conflicts \
#    -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


#echo "waiting for argo cd..."

#kubectl wait \
#    --for=condition=available \
#    --timeout=300s \
#    deployment/argocd-server \
#    -n argocd


## -------------------------
## argo cd application
## -------------------------

#echo "deploying argo cd application..."

#kubectl apply \
#    -f /home/vagrant/confs/argocd-app.yaml


## -------------------------
## argo cd port forward
## -------------------------

#cat <<'eof' > /etc/systemd/system/argocd-port-forward.service
#[unit]
#description=argo cd port forward
#after=network.target

#[service]
#type=simple
#user=root

#execstart=/usr/local/bin/kubectl port-forward \
#    -n argocd \
#    svc/argocd-server \
#    9443:443 \
#    --address=0.0.0.0

#restart=always
#restartsec=5

#[install]
#wantedby=multi-user.target
#eof


#systemctl daemon-reload
#systemctl enable --now argocd-port-forward.service


## -------------------------
## information
## -------------------------

#echo ""
#echo "=========================================="
#echo " argo cd"
#echo "=========================================="

#echo "url:"
#echo "https://192.168.56.110:9443"

#echo ""
#echo "username:"
#echo "admin"

#echo ""
#echo "password:"

#kubectl get secret argocd-initial-admin-secret \
#    -n argocd \
#    -o jsonpath="{.data.password}" | base64 -d

#echo ""
#echo ""

#echo "application:"
#echo "http://192.168.56.110:8888"

#echo ""
#echo "argo cd port-forward service:"
#echo "systemctl status argocd-port-forward"
#echo ""

#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# -------------------------
# Docker
# -------------------------

if ! command -v k3d &>/dev/null; then
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
fi


# -------------------------
# Create k3d cluster
# -------------------------

if ! k3d cluster get iot &>/dev/null; then
    k3d cluster create iot \
        --port "8080:80@loadbalancer"
fi


echo "Waiting for Kubernetes..."

until kubectl get nodes &>/dev/null; do
    sleep 2
done

echo "Kubernetes is ready."


# -------------------------
# Namespaces
# -------------------------

kubectl create namespace argocd \
    --dry-run=client -o yaml | kubectl apply -f -

kubectl create namespace dev \
    --dry-run=client -o yaml | kubectl apply -f -


# -------------------------
# Argo CD
# -------------------------

echo "Installing Argo CD..."

kubectl apply \
    -n argocd \
    --server-side \
    --force-conflicts \
    -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


echo "Waiting for Argo CD..."

kubectl wait \
    --for=condition=available \
    --timeout=300s \
    deployment/argocd-server \
    -n argocd


echo "Deploying Argo CD Application..."

kubectl apply \
    -f ./confs/argocd-app.yaml

kubectl apply -f ./confs/ingress.yaml

echo ""
echo "=========================================="
echo " Argo CD"
echo "=========================================="

echo "URL:"
echo "https://localhost:9443"

echo ""
echo "Username:"
echo "admin"

echo ""
echo "Password:"

kubectl get secret argocd-initial-admin-secret \
    -n argocd \
    -o jsonpath="{.data.password}" | base64 -d

echo ""
echo ""

echo "Application:"
echo "http://localhost:8080"

echo ""
echo "Argo CD port-forward service:"
echo "systemctl status argocd-port-forward"
echo ""

kubectl port-forward -n argocd svc/argocd-server 9443:443