# -*- mode: ruby -*-
# vi: set ft=ruby :

case Vagrant::VERSION
when /^1\.[1-4]/
  Vagrant.require_plugin('oscar')
else
  # The require_plugin call is deprecated in 1.5.x. Replacement??
end

if defined? Oscar
  class ReloadPluginSupport < ::ConfigBuilder::Model::Base
    def to_proc
      Proc.new do |vm_config|
        vm_config.provision :reload
      end
    end

    ::ConfigBuilder::Model::Provisioner.register('reload', self)
  end

  vagrantdir = File.dirname(__FILE__)
  configdir  = File.expand_path('config', vagrantdir)

  Vagrant.configure('2', &Oscar.run(configdir))

end
#
# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
#Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
#  config.vm.box = "puppetlabs/ubuntu-14.04-64-nocm"
#  config.vm.hostname = "conjur.local"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
#  config.vm.network "forwarded_port", guest: 443, host: 4443
#  config.vm.network "forwarded_port", guest: 8443, host: 8443
#  config.vm.network "forwarded_port", guest: 636, host: 6636
#  config.vm.network "forwarded_port", guest: 5432, host: 5432 

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
#  config.vm.provider "virtualbox" do |vb|
#     # Customize the amount of memory on the VM:
#     vb.memory = "1024"
#  end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
#  config.vm.provision "shell", inline: <<-SHELL
#     sudo apt-get --force-yes update
#     sudo apt-get install -yqq puppet
#  SHELL


#  config.vm.provision "puppet" do |puppet|
#    puppet.module_path = "modules"
#  end

#end
