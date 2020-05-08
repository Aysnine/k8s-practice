# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  $num_instances = 2
  $etcd_cluster = "node1=http://192.168.100.101:2380" # master

  config.vm.box_check_update = false
  config.vm.synced_folder "./node-config", "/vagrant", type: "rsync"

  (1..$num_instances).each do |i|
    config.vm.define "node#{i}" do |node|
      ip = "192.168.100.#{i+100}"
      node.vm.box = "MyCentos7"
      node.vm.hostname = "node#{i}"
      node.vm.network "private_network", ip: ip
      node.vm.provider "virtualbox" do |v|
        v.cpus = 2
        v.gui = false
        v.memory = 2048
        v.name = "node#{i}"
      end
      node.vm.provision "shell", path: "init-node.sh", args: [i, ip, $etcd_cluster]
    end
  end
end
