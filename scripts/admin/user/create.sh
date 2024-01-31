#!/usr/bin/env bash

source .env

# Get the user name from the first argument
export USER_NAME=$1
# Get the path to the ssh-pub-key from the first argument
export USER_SSH_PUB_KEY_PATH=$2

# A helper script to make calling Ansible easier
export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_CALLBACKS_ENABLED=profile_tasks
# Create the user with the specified ssh-pub-key, name
ansible-playbook -i "$INVENTORY_PATH" \
  -u "$USER" \
  -e "user_name=$USER_NAME" \
  -e "user_ssh_pub_key_path=$USER_SSH_PUB_KEY_PATH" \
  ./ansible/admin/user/create.yml