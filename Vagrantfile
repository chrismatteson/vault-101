# -*- mode: ruby -*-
# vi: set ft=ruby :

server_count = ENV['SERVER_COUNT'] || "3"


Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "512"]
    vb.customize ["modifyvm", :id, "--cpus", "1"]
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
    vb.customize ["modifyvm", :id, "--chipset", "ich9"]
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
  end
  (1..3).each do |i|
    config.vm.define "vault#{i}" do |node|
      node.vm.box = "bento/centos-7.3"
      node.vm.box_version = "2.3.8"
      node.vm.hostname = "vault#{i}"
      node.vm.network :private_network, ip: "192.168.50.15#{i}"
      node.vm.provision "shell", path: "scripts/setup-user.sh", args: "vault"
      node.vm.provision "shell", path: "scripts/setup-user.sh", args: "consul"
      node.vm.provision "shell", path: "scripts/base.sh"
      node.vm.provision "shell", path: "scripts/install-vault.sh"
      node.vm.provision "shell", path: "scripts/install-consul.sh"
      node.vm.provision "shell", path: "scripts/install-systemd-scripts.sh"
      node.vm.provision "shell", path: "scripts/install-configs.sh", args: server_count
      node.vm.provision "shell", inline: "sudo systemctl enable consul.service"
      node.vm.provision "shell", inline: "sudo systemctl start consul"
      node.vm.provision "shell", inline: "sudo systemctl enable vault.service"
      node.vm.provision "shell", inline: "sudo systemctl start vault"
    end
  end
  config.vm.define "database" do |database|
    database.vm.box = "bento/centos-7.3"
    database.vm.box_version = "2.3.8"
    database.vm.hostname = "database"
    database.vm.network :private_network, ip: "192.168.50.154"
    database.vm.provision "shell", path: "scripts/setup-user.sh", args: "postgres"
    database.vm.provision "shell", path: "scripts/base.sh"
    database.vm.provision "shell", path: "scripts/install-postgres.sh"
    database.vm.provision "shell", inline: "sudo systemctl enable postgresql.service"
    database.vm.provision "shell", inline: "sudo systemctl start postgresql"
  end
end
