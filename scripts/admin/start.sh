#!/usr/bin/env bash

source .env

# TODO: paramterize domain, docs on setting up domain dns
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i "$INVENTORY_PATH".admin \
  -u "admin" \
  ./ansible/admin/start.yml