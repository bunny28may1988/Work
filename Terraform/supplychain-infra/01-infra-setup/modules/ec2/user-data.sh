#!/bin/bash

setenforce 0

sed -i 's/enforcing/disabled/g' /etc/selinux/config
systemctl disable --now firewalld
systemctl mask firewalld

# Create a new app user which Arcos will use to login to jump host
useradd app_user
echo "Kotak@123" | passwd app_user --stdin
echo "vacheck" | passwd root --stdin

# Ensure that Arcos team is able to login to this Jump hosts using default root user
usermod -aG wheel app_user
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl restart sshd

# Install some additional tools required on the jump hosts
echo "y" | sudo amazon-linux-extras install postgresql14

# Create a local scratch directory which app_user can own and store files inside
mkdir -p /local/data/scratch
chown -R app_user:app_user /local/data/scratch
chmod -R 775 /local/data/scratch
