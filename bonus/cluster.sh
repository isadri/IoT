#!/bin/bash

set -e

CLUSTER_NAME="iot"

if [[ "$1" == "create" ]]; then
    if [[ ! -d .venv ]]; then
        python3 -m venv .venv
    fi

    echo "  Create .venv"
    python3 -m venv .venv

    echo "  Install Ansible and any dependencies"
    pip install -r requirements.txt

    echo "  Install Ansible requirements"
    ansible-galaxy install -r requirements.yaml

    ansible-playbook main.yaml --extra-vars=cluster_name="$CLUSTER_NAME"

elif [[ "$1" == "delete" ]]; then
    k3d cluster delete "$CLUSTER_NAME"
else
    echo "Usage: $0 [create|delete]" >&2
fi
