#!/usr/bin/env bash

source .env

# Ensure the Domain is formatted correctly
if [[ ! $DOMAIN =~ ^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,6}$ ]]; then
  echo "Invalid domain format. Please provide a valid domain."
  exit 1
fi

# Ensure the email is formatted correctly
if [[ ! $EMAIL =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
  echo "Invalid email format. Please provide a valid email."
  exit 1
fi

# Start the nginx server on the host 
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i "$INVENTORY_PATH".admin \
  -u "admin" \
  -e "domain=$DOMAIN" \
  -e "email=$EMAIL" \
  ./ansible/admin/nginx.yml