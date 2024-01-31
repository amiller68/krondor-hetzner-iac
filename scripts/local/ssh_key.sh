#!/usr/bin/env bash

# A path under ~/.ssh/ to store the new key
export SSH_PATH_NAME=$1

# Exit if the SSH_PATH_NAME is not set
if [ -z "$SSH_PATH_NAME" ]; then
  echo "SSH_PATH_NAME is not set"
  exit 1
fi

export SSH_PATH=$HOME/.ssh/$SSH_PATH_NAME


# Create the SSH_PATH if it doesn't exist -- but not the file
mkdir -p $(dirname $SSH_PATH)

echo "Creating SSH key at $SSH_PATH"

ansible-playbook \
    -e "ssh_path=$SSH_PATH" \
    ./ansible/local/ssh_key.yml