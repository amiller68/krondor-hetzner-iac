#!/usr/bin/env bash

ansible-playbook -i ./hosts/local \
    ./ansible/local/terminal/setup.yml