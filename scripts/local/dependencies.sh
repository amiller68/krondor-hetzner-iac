#!/usr/bin/env bash

ansible-playbook -i ./hosts/local \
    --ask-become-pass \
    ./ansible/local/dependencies.yml