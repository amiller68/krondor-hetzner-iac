#!/usr/bin/env bash

source .env

# Get the user name from the first argument
export SERVICE_NAME=$1

export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i "$INVENTORY_PATH".admin \
  -u "admin" \
  -e "service_name=$SERVICE_NAME" \
  ./ansible/admin/service/create.yml