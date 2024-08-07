#!/usr/bin/env bash

source .env

# Install dependencies on the host
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i "$INVENTORY_PATH" \
  -u "root" \
  ./ansible/dependencies.yml