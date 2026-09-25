#!/bin/bash

set -e

if [[ "$1" == "create" ]]; then
    if [[ ! -d .venv ]]; then
        python3 -m venv .venv
    fi

    echo "  Create .venv"
    python3 -m venv .venv

    echo "  Activate the virtual environment"
    source .venv/bin/activate

    echo "  Install Ansible and any dependencies"
    pip install -r requirements.txt

    ansible-playbook main.yaml --ask-become-pass

elif [[ "$1" == "delete" ]]; then
    k3d cluster delete "$CLUSTER_NAME"
else
    echo "Usage: $0 [create|delete]" >&2
fi
