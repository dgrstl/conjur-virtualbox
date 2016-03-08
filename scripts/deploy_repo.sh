#!/bin/bash

echo "Create private key used by Code manager"
ssh_key_dir='/etc/puppetlabs/puppetserver/ssh'
mkdir -p ${ssh_key_dir}
ssh-keygen -t rsa -b 4096 -C "demo@puppetlabs.com" -f ${ssh_key_dir}/id-control_repo.rsa -q -N ""
chown -R pe-puppet:pe-puppet ${ssh_key_dir}

mkdir -p /etc/puppetlabs/puppetserver/.puppetlabs/

echo "Create a deployment role"
/opt/puppetlabs/puppet/bin/curl -k -X POST -H 'Content-Type: application/json' \
	https://`facter fqdn`:4433/rbac-api/v1/roles \
	-d '{"permissions": [{"object_type": "environment", "action": "deploy_code", "instance": "*"},
{"object_type": "tokens", "action": "override_lifetime", "instance": "*"}],"user_ids": [], "group_ids": [], "display_name": "Deploy Environments", "description": "Ability to deploy environment"}' \
	--cert /`puppet config print ssldir`/certs/`facter fqdn`.pem \
	--key /`puppet config print ssldir`/private_keys/`facter fqdn`.pem \
	--cacert /`puppet config print ssldir`/certs/ca.pem

echo "Create a deployment user"
/opt/puppetlabs/puppet/bin/curl -k -X POST -H 'Content-Type: application/json' \
	https://`facter fqdn`:4433/rbac-api/v1/users \
	-d '{"login": "deploy", "password": "puppetlabs", "email": "", "display_name": "", "role_ids": [4]}' \
	--cert /`puppet config print ssldir`/certs/`facter fqdn`.pem \
	--key /`puppet config print ssldir`/private_keys/`facter fqdn`.pem \
	--cacert /`puppet config print ssldir`/certs/ca.pem

echo "Create a token"
/opt/puppetlabs/puppet/bin/curl -k -X POST -H 'Content-Type: application/json' \
	-d '{"login": "deploy", "password": "puppetlabs", "lifetime": "0"}' \
	https://`facter fqdn`:4433/rbac-api/v1/auth/token \
	| /opt/puppetlabs/puppet/bin/ruby -e 'require "json"; puts JSON.load(STDIN.read)["token"]' \
	> /etc/puppetlabs/puppetserver/.puppetlabs/deploy_token

echo "Invoking a deployment... "
# -w 'response: %{http_code} \n'
curl -v -k -X POST -H 'Content-Type: application/json' \
	https://`facter fqdn`:8170/code-manager/v1/deploys?token=`cat /etc/puppetlabs/puppetserver/.puppetlabs/deploy_token` \
	-d '{"environments": ["production"], "wait": true}' | cat
