#!/usr/bin/env bash

source .env

export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i "$INVENTORY_PATH".admin \
  -u "admin" \
  ./ansible/admin/setup/dependencies.yml