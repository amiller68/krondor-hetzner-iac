#!/usr/bin/env bash

ansible-playbook \
    --ask-become-pass \
    ./ansible/local/dependencies.yml