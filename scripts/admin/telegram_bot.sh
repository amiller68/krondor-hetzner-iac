#!/usr/bin/env bash

source .env

# Start the nginx server on the host 
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i "$INVENTORY_PATH".admin \
  -u "admin" \
  --extra-vars "tg_token=$TG_TOKEN" \
  ./ansible/admin/telegram_bot.yml