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

sed -i 's/--hostname-override=[^ ]*//g' /etc/eks/kubelet/environment
sed -i 'N;/\n}/{s//,&/;P;s/".*,/"eventRecordQPS": 0/};P;D' /etc/kubernetes/kubelet/config.json
systemctl restart kubelet
yum update -y && yum autoremove -y
sleep 20
#yum install rsync aide -y
yum install aide -y
sleep 20
touch /var/log/vaca.log
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
#rsync -auluXpogtr /var/* /var_new
cp -Rax /var/* /var_new 
shopt -u dotglob
#yum remove rsync -y
#sleep 20
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
#yum remove cronie rsync -y
yum remove cronie -y
#yum install aide -y
sleep 20
echo "umask 027" >> /etc/bashrc
echo "umask 027" >> /etc/profile
echo "umask 027" >> /etc/profile.d/which2.sh
echo "umask 027" >> /etc/profile.d/less.sh
echo "umask 027" >> /etc/profile.d/lang.sh
echo "umask 027" >> /etc/profile.d/colorls.sh
echo "umask 027" >> /etc/profile.d/colorgrep.sh
echo "umask 027" >> /etc/profile.d/256term.sh
systemctl disable nfs
systemctl stop nfs
systemctl mask nfs
systemctl disable nfs-server
systemctl stop nfs-server
systemctl mask nfs-server
systemctl disable rpcbind
systemctl stop rpcbind
systemctl mask rpcbind
echo "-w /etc/sudoers -p wa -k scope" >> /etc/audit/rules.d/audit.rules
echo "-w /etc/sudoers.d/ -p wa -k scope" >> /etc/audit/rules.d/audit.rules
echo "-w /sbin/insmod -p x -k modules" >> /etc/audit/rules.d/audit.rules
echo "-w /sbin/rmmod -p x -k modules" >> /etc/audit/rules.d/audit.rules
echo "-w /sbin/modprobe -p x -k modules" >> /etc/audit/rules.d/audit.rules
echo "-a always,exit -F arch=b64 -S init_module -k module-load" >> /etc/audit/rules.d/audit.rules
echo "-a always,exit -F arch=b32 -S init_module -k module-load" >> /etc/audit/rules.d/audit.rules
echo "-a always,exit -F arch=b64 -S delete_module -k module-unload" >> /etc/audit/rules.d/audit.rules
echo "-a always,exit -F arch=b32 -S delete_module -k module-unload" >> /etc/audit/rules.d/audit.rules
echo "-a always,exit -F arch=b64 -S mount -F success=1 -k mounts" >> /etc/audit/rules.d/audit.rules
echo "-a always,exit -F arch=b32 -S mount -F success=1 -k mounts" >> /etc/audit/rules.d/audit.rules
echo "-w /var/run/faillock/ -p wa -k logins" >> /etc/audit/rules.d/audit.rules
echo "-w /var/log/lastlog -p wa -k logins" >> /etc/audit/rules.d/audit.rules
echo "-w /var/log/tallylog -p wa -k logins" >> /etc/audit/rules.d/audit.rules
echo "-w /etc/selinux/ -p wa -k MAC-policy" >> /etc/audit/rules.d/audit.rules
echo "-w /usr/share/selinux/ -p wa -k MAC-policy" >> /etc/audit/rules.d/audit.rules
echo "-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod" >> /etc/audit/rules.d/audit.rules
echo "-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod" >> /etc/audit/rules.d/audit.rules
echo "-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod" >> /etc/audit/rules.d/audit.rules
echo "-a always,exit -F arch=b64 -S fchmod,fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod" >> /etc/audit/rules.d/audit.rules
echo "-a always,exit -F arch=b64 -S fchown -S fchownat -F auid>=1000 -F auid!=4294967295 -k perm_mod" >> /etc/audit/rules.d/audit.rules
echo "-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod" >> /etc/audit/rules.d/audit.rules
echo "-w /var/run/utmp -p wa -k session" >> /etc/audit/rules.d/audit.rules
echo "-w /var/log/wtmp -p wa -k session" >> /etc/audit/rules.d/audit.rules
echo "-w /var/log/btmp -p wa -k session" >> /etc/audit/rules.d/audit.rules
echo "-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change" >> /etc/audit/rules.d/audit.rules
echo "-a always,exit -F arch=b32 -S clock_settime -k time-change" >> /etc/audit/rules.d/audit.rules
echo "-w /etc/localtime -p wa -k time-change" >> /etc/audit/rules.d/audit.rules
echo "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change" >> /etc/audit/rules.d/audit.rules
echo "-a always,exit -F arch=b64 -S clock_settime -k time-change" >> /etc/audit/rules.d/audit.rules
echo "-w /etc/group -p wa -k identity" >> /etc/audit/rules.d/audit.rules
echo "-w /etc/passwd -p wa -k identity" >> /etc/audit/rules.d/audit.rules
echo "-w /etc/gshadow -p wa -k identity" >> /etc/audit/rules.d/audit.rules
echo "-w /etc/shadow -p wa -k identity" >> /etc/audit/rules.d/audit.rules
echo "-w /etc/security/opasswd -p wa -k identity" >> /etc/audit/rules.d/audit.rules
echo "-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale" >> /etc/audit/rules.d/audit.rules
echo "-w /etc/issue -p wa -k system-locale" >> /etc/audit/rules.d/audit.rules
echo "-w /etc/issue.net -p wa -k system-locale" >> /etc/audit/rules.d/audit.rules
echo "-w /etc/hosts -p wa -k system-locale" >> /etc/audit/rules.d/audit.rules
echo "-w /etc/sysconfig/network -p wa -k system-locale" >> /etc/audit/rules.d/audit.rules
echo "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale" >> /etc/audit/rules.d/audit.rules
echo "-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access" >> /etc/audit/rules.d/audit.rules
echo "-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access" >> /etc/audit/rules.d/audit.rules
echo "-a always,exit -F arch=b64 -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access" >> /etc/audit/rules.d/audit.rules
echo "-a always,exit -F arch=b64 -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -k access" >> /etc/audit/rules.d/audit.rules
echo "-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete" >> /etc/audit/rules.d/audit.rules
echo "-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete" >> /etc/audit/rules.d/audit.rules
echo "-e 2" >> /etc/audit/rules.d/audit.rules
augenrules --load
groupadd sugroup 
echo "auth required pam_wheel.so use_uid group=sugroup" >> /etc/pam.d/su
mount -o remount,noexec /dev/shm
egrep -q "^(\s*)net.ipv4.conf.all.accept_redirects\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv4.conf.all.accept_redirects\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.all.accept_redirects = 0\2/" /etc/sysctl.conf || echo "net.ipv4.conf.all.accept_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.accept_redirects = 0" >> /etc/sysctl.conf
sysctl -w net.ipv4.conf.all.accept_redirects=0
sysctl -w net.ipv4.conf.default.accept_redirects=0
sysctl -w net.ipv4.route.flush=1
egrep -q "^(\s*)net.ipv4.conf.all.secure_redirects\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv4.conf.all.secure_redirects\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.all.secure_redirects = 1\2/" /etc/sysctl.conf || echo "net.ipv4.conf.all.secure_redirects = 0" >> /etc/sysctl.conf
egrep -q "^(\s*)net.ipv4.conf.default.secure_redirects\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv4.conf.default.secure_redirects\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.default.secure_redirects = 1\2/" /etc/sysctl.conf || echo "net.ipv4.conf.default.secure_redirects = 0" >> /etc/sysctl.conf
sysctl -w net.ipv4.conf.all.secure_redirects=0
sysctl -w net.ipv4.conf.default.secure_redirects=0
sysctl -w net.ipv4.route.flush=1
egrep -q "^(\s*)net.ipv4.conf.all.log_martians\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv4.conf.all.log_martians\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.all.log_martians = 1\2/" /etc/sysctl.conf || echo "net.ipv4.conf.all.log_martians = 1" >> /etc/sysctl.conf
egrep -q "^(\s*)net.ipv4.conf.default.log_martians\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv4.conf.default.log_martians\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv4.conf.default.log_martians = 1\2/" /etc/sysctl.conf || echo "net.ipv4.conf.default.log_martians = 1" >> /etc/sysctl.conf
sysctl -w net.ipv4.conf.all.log_martians=1
sysctl -w net.ipv4.conf.default.log_martians=1
sysctl -w net.ipv4.route.flush=1
egrep -q "^(\s*)net.ipv6.conf.all.accept_ra\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv6.conf.all.accept_ra\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv6.conf.all.accept_ra = 0\2/" /etc/sysctl.conf || echo "net.ipv6.conf.all.accept_ra = 0" >> /etc/sysctl.conf
egrep -q "^(\s*)net.ipv6.conf.default.accept_ra\s*=\s*\S+(\s*#.*)?\s*$" /etc/sysctl.conf && sed -ri "s/^(\s*)net.ipv6.conf.default.accept_ra\s*=\s*\S+(\s*#.*)?\s*$/\1net.ipv6.conf.default.accept_ra = 0\2/" /etc/sysctl.conf || echo "net.ipv6.conf.default.accept_ra = 0" >> /etc/sysctl.conf
sysctl -w net.ipv6.conf.all.accept_ra=0
sysctl -w net.ipv6.conf.default.accept_ra=0
sysctl -w net.ipv6.route.flush=1

sysctl -w net.ipv4.conf.all.send_redirects=0
sysctl -w net.ipv4.conf.default.send_redirects=0
ip6tables -A INPUT -i lo -j ACCEPT
ip6tables -A OUTPUT -o lo -j ACCEPT
ip6tables -A INPUT -s ::1 -j DROP
ip6tables -P INPUT DROP
ip6tables -P OUTPUT DROP
ip6tables -P FORWARD DROP
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -s 127.0.0.0/8 -j DROP
cat >> /etc/profile << EOL
TMOUT=900
readonly TMOUT
export TMOUT
EOL
cat >> /etc/bashrc << EOL
TMOUT=900
readonly TMOUT
export TMOUT
EOL
egrep -q "^(\s*)PASS_MAX_DAYS\s+\S+(\s*#.*)?\s*$" /etc/login.defs && sed -ri "s/^(\s*)PASS_MAX_DAYS\s+\S+(\s*#.*)?\s*$/\PASS_MAX_DAYS 365\2/" /etc/login.defs || echo "PASS_MAX_DAYS 365" >> /etc/login.defs
egrep -q "^(\s*)PASS_MIN_DAYS\s+\S+(\s*#.*)?\s*$" /etc/login.defs && sed -ri "s/^(\s*)PASS_MIN_DAYS\s+\S+(\s*#.*)?\s*$/\PASS_MIN_DAYS 7\2/" /etc/login.defs || echo "PASS_MIN_DAYS 7" >> /etc/login.defs
egrep -q "^(\s*)X11Forwarding\s+\S+(\s*#.*)?\s*$" /etc/ssh/sshd_config && sed -ri "s/^(\s*)X11Forwarding\s+\S+(\s*#.*)?\s*$/\1X11Forwarding no\2/" /etc/ssh/sshd_config || echo "X11Forwarding no" >> /etc/ssh/sshd_config
systemctl restart sshd
chmod 700 /etc/cron.daily    # applicable for EKS worker nodes
mkdir -p /etc/cron.hourly
chown root:root /etc/cron.hourly
chmod 700 /etc/cron.hourly
mkdir -p /etc/cron.weekly
chown root:root /etc/cron.weekly
chmod 700 /etc/cron.weekly
mkdir -p /etc/cron.monthly
chown root:root /etc/cron.monthly
chmod 700 /etc/cron.monthly
chmod -R 700 /etc/cron.d     # applicable for EKS worker nodes
chmod -R 740 /var/log/*
egrep -q "^(\s*)space_left_action\s*=\s*\S+(\s*#.*)?\s*$" /etc/audit/auditd.conf && sed -ri "s/^(\s*)space_left_action\s*=\s*\S+(\s*#.*)?\s*$/\1space_left_action = email\2/" /etc/audit/auditd.conf || echo "space_left_action = email" >> /etc/audit/auditd.conf
egrep -q "^(\s*)action_mail_acct\s*=\s*\S+(\s*#.*)?\s*$" /etc/audit/auditd.conf && sed -ri "s/^(\s*)action_mail_acct\s*=\s*\S+(\s*#.*)?\s*$/\1action_mail_acct = root\2/" /etc/audit/auditd.conf || echo "action_mail_acct = root" >> /etc/audit/auditd.conf
egrep -q "^(\s*)admin_space_left_action\s*=\s*\S+(\s*#.*)?\s*$" /etc/audit/auditd.conf && sed -ri "s/^(\s*)admin_space_left_action\s*=\s*\S+(\s*#.*)?\s*$/\1admin_space_left_action = halt\2/" /etc/audit/auditd.conf || echo "admin_space_left_action = halt" >> /etc/audit/auditd.conf
egrep -q "^(\s*)max_log_file_action\s*=\s*\S+(\s*#.*)?\s*$" /etc/audit/auditd.conf && sed -ri "s/^(\s*)max_log_file_action\s*=\s*\S+(\s*#.*)?\s*$/\1max_log_file_action = keep_logs\2/" /etc/audit/auditd.conf || echo "max_log_file_action = keep_logs" >> /etc/audit/auditd.conf
date >> /var/log/vaca.log
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
