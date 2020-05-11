# k8s 实践

*Don't use any proxy!!!*

- [kubernetes 从入门到实践](https://www.kancloud.cn/huyipow/kubernetes/531982)

## 虚拟环境搭建

- [Vagrant 搭建虚拟机集群](http://flygopher.top/post/vagrant-setup-virtual-machine-cluster/?nsukey=f2tCN3URnXJHcQ%2Famyuh4XhEC%2BcrAwnzUoonKqzhuelzA8I1hT%2ByLvMzczvscnAeegg4XXJ6sZABYJX85QKOncWePbwP1mBm0JVLMEoNtyjjS92BvGj7gLRpDb28YCc79fxL65CRbGYXBD6A2tfpEDFyN9C9g8FCD29BBqT7uR8mj5OqtVJrYfytByedOQ2ImW%2BXbjAAYwpX9XHX6NydHg%3D%3D)
- [使用kubeadm搭建Kubernetes集群](http://flygopher.top/post/kubeadm-install-kubernetes-cluster/)
- https://github.com/rootsongjc/kubernetes-vagrant-centos-cluster
- https://github.com/amuguelove/setup-kubernetes-cluster

### Vagrant + VirtualBox on Mac

[VirtualBox](https://www.virtualbox.org/)：[安装包](https://www.virtualbox.org/wiki/Downloads)，or `brew cask install virtualbox`
[Vagrant](https://www.vagrantup.com/) ：[安装包](https://www.vagrantup.com/downloads.html)，or `brew cask install vagrant`

### 定制 MyCentos7

``` bash
cd my-centos7

vagrant destroy -f && vagrant up

vagrant halt
mkdir -p ~/vagrant/
rm -f ~/vagrant/MyCentos7.box
vagrant box remove MyCentos7

vagrant package --base MyCentos7 --output ~/vagrant/MyCentos7.box
vagrant box add MyCentos7 ~/vagrant/MyCentos7.box
```

**ssh debug**

``` bash
vagrant up
rm -f .vagrant/machines/default/virtualbox/private_key
vagrant ssh default
```

### 运行集群

``` bash
vagrant up
```

### Dashboard

- [通用的dashboard部署和tls，SSL相关部署](https://zhangguanzhang.github.io/2019/02/12/dashboard/)

#### port-forward

*193.168.100.101:4443*

``` bash
vagrant ssh node1
kdashf # sudo kubectl port-forward -n kubernetes-dashboard svc/kubernetes-dashboard 4443:443 --address 0.0.0.0
```

#### NodePort

*193.168.100.101:32443*

- [How To Install Kubernetes Dashboard with NodePort](https://computingforgeeks.com/how-to-install-kubernetes-dashboard-with-nodeport/)

``` yaml
# vim /vagrant/dashboard/recommended.yaml

kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  ports:
    - port: 443
      targetPort: 8443
      nodePort: 32443 # here
  selector:
    k8s-app: kubernetes-dashboard
  type: NodePort # here
```

``` bash
# apply
kubectl apply -f /vagrant/dashboard/recommended.yaml
```

## Gitlab 搭建

- [kubernetes（k8s）Gitlab 的安装使用](https://www.jianshu.com/p/cd4aba71d19d)

TODO
