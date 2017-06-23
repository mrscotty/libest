# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "debian/contrib-jessie64"

  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y git-core automake make gcc libssl-dev
  SHELL
end
