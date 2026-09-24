#!/bin/bash
set -e

apt-get update -y
apt-get install -y curl

until [ -f /vagrant/node_token ]; do
  echo "Waiting for server token..."
  sleep 3
done

TOKEN=$(cat /vagrant/node_token)

curl -sfL https://get.k3s.io | \
  K3S_URL=https://192.168.56.110:6443 \
  K3S_TOKEN="$TOKEN" \
  sh -
