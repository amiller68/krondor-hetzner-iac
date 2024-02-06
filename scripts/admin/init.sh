#!/usr/bin/env bash

source .env

# TODO: paramterize domain, docs on setting up domain dns
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i "$INVENTORY_PATH".admin \
  -u "admin" \
  -e "domain=cloud.krondor.org" \
  -e "email=al@krondor.org" \
  ./ansible/admin/init.yml