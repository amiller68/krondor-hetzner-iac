#!/usr/bin/env bash

source .env

# TODO: paramterize domain, docs on setting up domain dns
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i "$INVENTORY_PATH".admin \
  -u "admin" \
  -e "domain=cloud.krondor.org" \
  -e "email=al@krondor.org" \
  -e "site_path=$(pwd)/scripts/admin/service/nginx/site" \
  -e "config_path=$(pwd)/scripts/admin/service/nginx/config.j2" \
  ./ansible/admin/service/nginx/start.yml