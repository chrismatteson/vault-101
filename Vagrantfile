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
  config.vm.define "vault1" do |vault1|
    vault1.vm.box = "bento/centos-7.3"
    vault1.vm.box_version = "2.3.8"
    vault1.vm.hostname = "vault1"
    vault1.vm.network :private_network, ip: "192.168.50.150"
  end

  config.vm.define "vault2" do |vault2|
    vault2.vm.box = "bento/centos-7.3"
    vault2.vm.box_version = "2.3.8"
    vault2.vm.hostname = "vault2"
    vault2.vm.network :private_network, ip: "192.168.50.151"
  end

  config.vm.define "vault3" do |vault3|
    vault3.vm.box = "bento/centos-7.3"
    vault3.vm.box_version = "2.3.8"
    vault3.vm.hostname = "vault3"
    vault3.vm.network :private_network, ip: "192.168.50.152"
  end
  config.vm.provision "shell", path: "scripts/setup-user.sh", args: "vault"
  config.vm.provision "shell", path: "scripts/setup-user.sh", args: "consul"
  config.vm.provision "shell", path: "scripts/base.sh"
  config.vm.provision "shell", path: "scripts/install-vault.sh"
  config.vm.provision "shell", path: "scripts/install-consul.sh"
  config.vm.provision "shell", path: "scripts/install-systemd-scripts.sh"
  config.vm.provision "shell", path: "scripts/install-configs.sh", args: server_count
  config.vm.provision "shell", inline: "sudo systemctl enable consul.service"
  config.vm.provision "shell", inline: "sudo systemctl start consul"
  config.vm.provision "shell", inline: "sudo systemctl enable vault.service"
  config.vm.provision "shell", inline: "sudo systemctl start vault"
end


Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "512"]
    vb.customize ["modifyvm", :id, "--cpus", "1"]
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", "50"]
    vb.customize ["modifyvm", :id, "--chipset", "ich9"]
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
  end
  config.vm.define "database" do |database|
    database.vm.box = "bento/centos-7.3"
    database.vm.box_version = "2.3.8"
    database.vm.hostname = "database"
    database.vm.network :private_network, ip: "192.168.50.154"
  end
  config.vm.provision "shell", path: "scripts/setup-user.sh", args: "postgres"
  config.vm.provision "shell", path: "scripts/base.sh"
  config.vm.provision "shell", path: "scripts/install-postgres.sh"
  config.vm.provision "shell", inline: "sudo systemctl enable postgresql.service"
  config.vm.provision "shell", inline: "sudo systemctl start postgresql"
end
