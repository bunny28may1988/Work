#!/bin/bash
setenforce 0
sed -i 's/enforcing/disabled/g' /etc/selinux/config 
systemctl disable --now firewalld
systemctl mask firewalld
useradd app_user
echo "Kotak@123" | passwd app_user --stdin
echo "vacheck" | passwd root --stdin
usermod -aG wheel app_user
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd
hostnamectl set-hostname KBPDEVOPL0001