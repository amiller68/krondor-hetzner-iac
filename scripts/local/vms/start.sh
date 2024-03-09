#!/bin/bash

# TODO: dynamically scale the number of VMs
# Start 3 local VMs for development
cd ./scripts/local/vms;
cd docker;
docker compose up -d

# list the running containers
DEBIAN_VM_1_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' debian_vm_1)
DEBIAN_VM_2_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' debian_vm_2)
DEBIAN_VM_3_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' debian_vm_3)

cd ../../../../hosts
mkdir -p local/vms
cd local/vms
echo 'all:' > inventory.yml
echo '  hosts:' >> inventory.yml
echo '    debian_vm_1:' >> inventory.yml
echo '      ansible_host: '$DEBIAN_VM_1_IP >> inventory.yml
echo '      ansible_port: 22' >> inventory.yml
echo '      ansible_user: admin' >> inventory.yml
echo '      ansible_ssh_pass: admin' >> inventory.yml
echo '    debian_vm_2:' >> inventory.yml
echo '      ansible_host: '$DEBIAN_VM_2_IP >> inventory.yml
echo '      ansible_port: 22' >> inventory.yml
echo '      ansible_user: admin' >> inventory.yml
echo '      ansible_ssh_pass: admin' >> inventory.yml
echo '    debian_vm_3:' >> inventory.yml
echo '      ansible_host: '$DEBIAN_VM_3_IP >> inventory.yml
echo '      ansible_port: 22' >> inventory.yml
echo '      ansible_user: admin' >> inventory.yml
echo '      ansible_ssh_pass: admin' >> inventory.yml