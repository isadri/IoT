#!/bin/bash
set -e

apt-get update -y
apt-get install -y curl

curl -sfL https://get.k3s.io | sh -s - server --write-kubeconfig-mode=644

# Wait for K3s to be ready
until kubectl get nodes &>/dev/null; do
  sleep 2
done

# Share token with worker via synced /vagrant folder
cp /var/lib/rancher/k3s/server/node-token /vagrant/node_token
chmod 644 /vagrant/node_token
