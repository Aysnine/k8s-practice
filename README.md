# k8s 实践

*Don't use any proxy!!!*

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

映射 dashboard：
``` bash
vagrant ssh node1
kdashf # port-forward k8s dashboard
```

## Gitlab 搭建

- [kubernetes（k8s）Gitlab 的安装使用](https://www.jianshu.com/p/cd4aba71d19d)

TODO

