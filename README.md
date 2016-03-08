# conjur-virtualbox

This project uses puppet and vagrant to create a virtual box appliance for Conjur.

It installs and configures:
* [Conjur Master](https://developer.conjur.net/server_setup/platforms/docker.html).
* [Conjur UI](https://developer.conjur.net/server_setup/tools/ui.html).
* [Puppet Enterprise 2015.3.2 Master](https://puppetlabs.com/puppet/puppet-enterprise).
* "Conjurized" hosts managed by Puppet.

## Prerequisites
* Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* Install [Vagrant](http://www.vagrantup.com/downloads.html)
* Install the following Vagrant plugins:
`$ vagrant plugin install oscar`
`$ vagrant plugin install vagrant-multiprovider-snap`
`$ vagrant plugin install vagrant-reload`
`$ vagrant plugin install vagrant-hosts`

## Running
1. Copy the docker container to this directory
2. `vagrant up`
3. `vagrant hosts puppetize | sudo puppet apply`
4. Access the PE console via https://master.inf.puppetlabs.demo (admin/puppetlabs)
5. Access the Conjur UI via https://conjur.puppetlabs.demo:8443 (admin/conjur)
6. Access the Conjur CLI via https://conjur.puppetlabs.demo:4443
