#!/usr/bin/env bash

# Create a new admin user on the host using root
#  Should disable root login after this is done

source .env

# Create the admin user -- should ask for a password that you got from the host provider
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i "$INVENTORY_PATH" \
  -u "root" \
  --ask-pass \
  -e "user_name=admin" \
  -e "user_ssh_pub_key_path=$ADMIN_PUB_KEY_PATH" \
  ./ansible/admin/create.yml