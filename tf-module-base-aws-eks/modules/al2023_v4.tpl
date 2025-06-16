MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="BOUNDARY"

--BOUNDARY
Content-Type: application/node.eks.aws

---
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster:
    apiServerEndpoint: ${api_ep}
    certificateAuthority: ${cert_auth}
    cidr: ${cidr}
    name: ${cluster_name}


--BOUNDARY
Content-Type: text/x-shellscript;

#!/usr/bin/env bash
# more bootstrap content

--BOUNDARY
Content-Type: text/x-shellscript;

#!/usr/bin/env bash

pvcreate /dev/nvme1n1
vgcreate vg_var /dev/nvme1n1
lvcreate -L 12G -n lv_var vg_var
lvcreate -L 2G -n lv_var_log vg_var
lvcreate -L 1G -n lv_var_tmp vg_var
lvcreate -L 3G -n lv_var_log_audit vg_var
mkfs.xfs /dev/mapper/vg_var-lv_var
mkfs.xfs /dev/mapper/vg_var-lv_var_log
mkfs.xfs /dev/mapper/vg_var-lv_var_tmp
mkfs.xfs /dev/mapper/vg_var-lv_var_log_audit
mkdir -p /var_new
mount -t xfs /dev/mapper/vg_var-lv_var /var_new
mkdir -p /var_new/log
mkdir -p /var_new/tmp
mount -t xfs /dev/mapper/vg_var-lv_var_log /var_new/log
mkdir -p /var_new/log/audit
mount -t xfs /dev/mapper/vg_var-lv_var_tmp /var_new/tmp
mount -t xfs /dev/mapper/vg_var-lv_var_log_audit /var_new/log/audit
shopt -s dotglob
cp -Rax /var/* /var_new 
shopt -u dotglob
umount /var_new/log/audit
umount /var_new/log
umount /var_new/tmp
umount /var_new
rm -rf /var_new
mv /var /var-old
mkdir /var
echo "/dev/mapper/vg_var-lv_var /var xfs defaults,nofail,nodev 0 1" >> /etc/fstab
mount /var
echo "/dev/mapper/vg_var-lv_var_log /var/log xfs defaults,nofail,nodev,nosuid 0 1" >> /etc/fstab
mount /var/log
echo "/dev/mapper/vg_var-lv_var_log_audit /var/log/audit xfs defaults,nofail,nodev,nosuid 0 1" >> /etc/fstab
echo "/dev/mapper/vg_var-lv_var_tmp /var/tmp xfs defaults,nofail,nodev,nosuid,noexec 0 1" >> /etc/fstab
echo "tmpfs /tmp tmpfs defaults,nofail,nodev,nosuid,noexec 0 1" >> /etc/fstab
mount -a




sed -i 's/--hostname-override=[^ ]*//g' /etc/eks/kubelet/environment
sed -i 'N;/\n}/{s//,&/;P;s/".*,/"eventRecordQPS": 0/};P;D' /etc/kubernetes/kubelet/config.json

chmod -R 740 /var/log/*
find /etc/ssh/ -iname "*host*_key" -exec chown root:root {} \;
find /etc/ssh/ -iname "*host*_key" -exec chmod 600 {} \;
chown root:root /etc/ssh/ssh_host_ecdsa_key
chown root:root /etc/ssh/ssh_host_ed25519_key
sed 's/ClientAliveInterval 900/ClientAliveInterval 300/g' /etc/ssh/sshd_config
echo "Authorized uses only. All activity may be monitored and reported." > /etc/issue
echo "Authorized uses only. All activity may be monitored and reported." > /etc/issue.net

sysctl -w net.ipv4.conf.all.rp_filter=1 
sysctl -w net.ipv4.conf.default.rp_filter=1 
sysctl -w net.ipv4.conf.all.send_redirects=0
sysctl -w net.ipv4.conf.default.send_redirects=0

echo "tmpfs /tmp tmpfs defaults,nofail,nodev,nosuid,noexec 0 1" >> /etc/fstab
mount -a
mount -o remount,noexec /tmp
mount -o remount,noexec /dev/shm




echo 'export http_proxy=http://${proxy_ip}' >> /etc/environment
echo 'export HTTP_PROXY=http://${proxy_ip}' >> /etc/environment
echo 'export https_proxy=http://${proxy_ip}' >> /etc/environment
echo 'export HTTPS_PROXY=http://${proxy_ip}' >> /etc/environment
echo 'export no_proxy=172.20.0.0/16,localhost,127.0.0.1,${no_proxy_ip},169.254.169.254,.internal,.eks.amazonaws.com,.ec2.ap-south-1.amazonaws.com,.amazonaws.com' >> /etc/environment
echo 'export NO_PROXY=172.20.0.0/16,localhost,127.0.0.1,${no_proxy_ip},169.254.169.254,.internal,.eks.amazonaws.com,.ec2.ap-south-1.amazonaws.com,.amazonaws.com' >> /etc/environment
echo '[Service]' >> /etc/systemd/system/containerd.service.d/http-proxy.conf
echo 'Environment="http_proxy=http://${proxy_ip}"' >> /etc/systemd/system/containerd.service.d/http-proxy.conf
echo 'Environment="https_proxy=http://${proxy_ip}"' >> /etc/systemd/system/containerd.service.d/http-proxy.conf
echo 'Environment="no_proxy=172.20.0.0/16,localhost,127.0.0.1,${no_proxy_ip},169.254.169.254,.internal,.eks.amazonaws.com,.ec2.ap-south-1.amazonaws.com,.amazonaws.com"' >> /etc/systemd/system/containerd.service.d/http-proxy.conf
systemctl daemon-reload
systemctl restart containerd
systemctl restart kubelet
--BOUNDARY--