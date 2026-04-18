#!/bin/bash
# Script to run the CVAT development environment setup playbook

# Check if ansible is installed
if ! command -v ansible-playbook &> /dev/null; then
    echo "Ansible is not installed. Please install it first (e.g., sudo apt install ansible)."
    exit 1
fi

# Run the playbook
ansible-playbook setup_dev_env.yml
