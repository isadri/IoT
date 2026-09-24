#!/bin/bash
set -e

apt-get update -y
apt-get install -y curl

curl -sfL https://get.k3s.io | sh -

until kubectl get nodes &>/dev/null; do
	sleep 2
done

kubectl apply -f /vagrant/confs/
