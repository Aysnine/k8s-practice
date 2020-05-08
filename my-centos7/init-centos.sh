#!/usr/bin/env bash

echo 'update locale'
cat <<EOF | sudo tee -a /etc/environment
LANG=en_US.utf8
LC_CTYPE=en_US.utf8
EOF

echo 'update repos'
rm /etc/yum.repos.d/CentOS-Base.repo
rm -f /etc/yum.repos.d/epel*.repo
cp /vagrant/yum/*.* /etc/yum.repos.d/
yum clean all
yum makecache fast

echo 'install utils'
yum install -y git wget curl gtop vim htop \
  conntrack-tools net-tools telnet tcpdump bind-utils socat \
  ntp chrony kmod ceph-common dos2unix ipvsadm ipset bridge-utils

echo 'ctop for docker'
cp /vagrant/bin/ctop-0.7.3-linux-amd64 /usr/bin/ctop
chmod +x /usr/bin/ctop

echo 'disable selinux'
setenforce 0
sed -i 's/=enforcing/=disabled/g' /etc/selinux/config

echo 'enable iptable kernel parameter'
cat >> /etc/sysctl.conf <<EOF
net.ipv4.ip_forward=1
EOF
sysctl -p

echo 'optimize linux kernel parameters'
cp /vagrant/sysctl/kubernetes.conf  /etc/sysctl.d/kubernetes.conf
modprobe br_netfilter
modprobe ip_conntrack
sysctl -p /etc/sysctl.d/kubernetes.conf

echo 'change time zone'
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
timedatectl set-timezone Asia/Shanghai

echo 'sync time'
systemctl enable chronyd
systemctl start chronyd
timedatectl status
timedatectl set-local-rtc 0
systemctl restart rsyslog
systemctl restart crond

echo 'disable firewalld'
systemctl stop firewalld
systemctl disable firewalld
iptables -F && iptables -X && iptables -F -t nat && iptables -X -t nat
iptables -P FORWARD ACCEPT

echo 'disable useless system server'
systemctl stop postfix && systemctl disable postfix

echo 'disable swap'
swapoff -a
sed -i '/swap/s/^/#/' /etc/fstab

echo 'install docker'
yum install -y yum-utils device-mapper-persistent-data lvm2
yum -y install docker-ce-18.09.9

mkdir -p /etc/docker
cat /vagrant/docker/daemon.json > /etc/docker/daemon.json
cat /vagrant/systemd/docker.service > /usr/lib/systemd/system/docker.service

echo 'enable docker service'
systemctl daemon-reload
systemctl enable docker
systemctl start docker

echo 'install and enable kubeadm'
yum install -y kubelet-1.16.8 kubeadm-1.16.8 kubectl-1.16.8 --disableexcludes=kubernetes
systemctl enable --now kubelet

echo 'for custom vagrant box'
sudo -u vagrant cp /vagrant/vagrant.pub /home/vagrant/.ssh/authorized_keys
chmod go-w /home/vagrant/.ssh/authorized_keys

echo '============ info ============'
docker --version
docker info
kubelet --version
kubeadm version
