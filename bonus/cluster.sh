#!/bin/bash

set -e

CLUSTER_NAME="$2"

if [[ "$1" == "create" ]]; then
    if [[ ! -d .venv ]]; then
        python3 -m venv .venv
    fi

    echo "  Create .venv"
    python3 -m venv .venv

    echo "  Install Ansible and any dependencies"
    pip install -r requirements.txt

    ansible-playbook main.yaml --extra-vars=cluster_name="$CLUSTER_NAME"

elif [[ "$1" == "delete" ]]; then
    k3d cluster delete "$CLUSTER_NAME"
else
    echo "Usage: $0 [create|delete] <cluster-name>" >&2
fi
