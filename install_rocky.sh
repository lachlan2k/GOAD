#!/bin/bash

# Setup bridge interface for VMs
INTERNAL_NETWORK_IF=enp7s0

nmcli con add type bridge ifname br0 con-name br0
nmcli con add type bridge-slave ifname ${INTERNAL_NETWORK_IF} master br0
nmcli con up br0

dnf update -y
dnf install epel-release -y

# Get everything we need for libvirt
dnf group install -y "virtualization hypervisor"
dnf group install -y "virtualization tools"
systemctl enable --now libvirtd

# Install vagrant
dnf config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
dnf install -y vagrant

# Install libvirt plugin
dnf config-manager --set-enabled crb
dnf install -y libvirt-devel

dnf group install -y "development tools"
vagrant plugin install vagrant-libvirt

# Install git and podman (podman is used for running ansible)
dnf install -y git podman

cd /opt
git clone https://github.com/lachlan2k/GOAD
cd GOAD

# Change from 192.168.56.0/24 to 10.13.5.0/24
find . -type f | xargs sed -i "s/192\.168\.56/10\.13\.5/g"

vagrant up

podman build -t goadansible .
time podman run -it --rm --network host -h goadansible -v $(pwd):/goad -w /goad/ansible goadansible ansible-playbook main.yml
