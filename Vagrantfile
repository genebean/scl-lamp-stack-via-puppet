# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "genebean/centos-7-puppet"

  if Vagrant.has_plugin?("vagrant-cachier")
    # Configure cached packages to be shared between instances of the same base box.
    # More info on http://fgrehm.viewdocs.io/vagrant-cachier/usage
    config.cache.scope = :box
  end

  config.vm.network "forwarded_port", guest: 80,   host: 8080
  config.vm.network "forwarded_port", guest: 443,  host: 8443

  config.vm.provision "shell", inline: <<-SHELL1
    yum -y install cmake gcc gcc-c++ git python-devel ruby-devel vim
    gem install --no-ri --no-rdoc bundler
    puppet module install puppetlabs-apache
    puppet apply /vagrant/site.pp
  SHELL1

#  config.vm.provision "shell", path: vim-setup.sh

end
