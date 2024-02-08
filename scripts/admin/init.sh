#!/usr/bin/env bash

# Create a new admin user on the host using root
#  Should disable root login after this is done

source .env

export ADMIN_PUB_KEY_PATH=${ADMIN_KEY_PATH}.pub

# Initialize the server with an admin user -- should ask for a password that you got from the host provider
#  This should disable root login / password after this is done
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i "$INVENTORY_PATH" \
  -u "root" \
  --ask-pass \
  -e "admin_ssh_pub_key_path=$ADMIN_PUB_KEY_PATH" \
  ./ansible/admin/init.yml