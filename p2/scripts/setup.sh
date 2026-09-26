#!/bin/bash
set -e

apt-get update -y
apt-get install -y curl

curl -sfL https://get.k3s.io | sh -s - server --write-kubeconfig-mode=644 --node-ip=192.168.56.110

until kubectl get nodes &>/dev/null; do
	sleep 2
done

kubectl apply -f /vagrant/confs/
