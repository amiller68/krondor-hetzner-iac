#!/usr/bin/env bash

source env/env.host
source env/env.user

# A helper script to make calling Ansible easier
export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_CALLBACKS_ENABLED=profile_tasks
ansible-playbook -i "$ANSIBLE_INVENTORY" \
  -u "$USER" \
  ./ansible/admin/setup/dependencies.yml