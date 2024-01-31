#!/usr/bin/env bash

source .env

# Get the user name from the first argument
export USER_NAME=$1
# Get the path to the ssh-pub-key from the first argument
export USER_SSH_PUB_KEY_PATH=$2

# Make sure the path ends in .pub
if [[ ! $USER_SSH_PUB_KEY_PATH == *.pub ]]; then
  echo "The path to the ssh-pub-key must end in .pub"
  exit 1
fi

export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i "$INVENTORY_PATH".admin \
  -u "admin" \
  -e "user_name=$USER_NAME" \
  -e "user_ssh_pub_key_path=$USER_SSH_PUB_KEY_PATH" \
  ./ansible/admin/user/create.yml