#!/usr/bin/env bash

echo 'set host name resolution'
cat /vagrant/hosts >> /etc/hosts
cat /etc/hosts

echo '/sbin/iptables -P FORWARD ACCEPT' >> /etc/rc.local

cat /vagrant/ipvs.modules > /etc/sysconfig/modules/ipvs.modules
chmod 755 /etc/sysconfig/modules/ipvs.modules && \
  bash /etc/sysconfig/modules/ipvs.modules && \
    lsmod | grep -e ip_vs -e nf_conntrack_ipv4

# for master node
if [[ $1 -eq 1 ]]
then
  echo 'kubeadm-init.yaml'
  cat /vagrant/kubeadm-init.yaml

  echo 'pull core images'
  kubeadm config images pull --config /vagrant/kubeadm-init.yaml
  for image in $(docker images | awk '{ if( FNR>1 ) { print $1":"$2 } }' | grep registry.aliyuncs.com/google_containers)
  do \
    INAME=`echo $image | cut -f1 -d":"`
    INAME_NEW="${INAME/registry.aliyuncs.com\/google_containers/k8s.gcr.io}"
    ITAG=`echo $image | cut -f2 -d":"`
    echo "from ${INAME}:${ITAG} to ${INAME_NEW}:${ITAG}"
    docker tag $image $INAME_NEW:$ITAG
    docker rmi $image
  done
  docker images

  echo 'kubeadm init'
  kubeadm init --config /vagrant/kubeadm-init.yaml
  echo 'alias ksys="sudo kubectl get pods -n kube-system"' >> .bashrc
  echo 'alias kj="sudo kubeadm token create --print-join-command"' >> .bashrc

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

  echo 'apply flannel'
  kubectl apply -f /vagrant/kube-flannel.yml

  echo 'master untainted'
  kubectl taint nodes --all node-role.kubernetes.io/master-

  echo 'apply dashboard'
  kubectl apply -f /vagrant/dashboard/recommended.yaml
  kubectl apply -f /vagrant/dashboard/admin.yaml
  echo 'alias kdash="sudo kubectl get pods -n kubernetes-dashboard && sudo kubectl get svc -n kubernetes-dashboard"' >> .bashrc
  echo 'alias kdashf="sudo kubectl port-forward -n kubernetes-dashboard svc/kubernetes-dashboard 4443:443 --address 0.0.0.0"' >> .bashrc

  echo 'Please run [kdashf] and open https://192.168.100.101:4443'
  echo '=================== admin token ==============='
  kubectl -n kube-system describe secret `kubectl -n kube-system get secret|grep admin-token|cut -d " " -f1`|grep "token:"|tr -s " "|cut -d " " -f2
  echo '==============================================='
fi

if [[ $1 -gt 1 ]]
then
  echo 'Please join to master with sudo'
fi
