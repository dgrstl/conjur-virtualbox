#!/bin/bash

# this script deploys using the tar.gz found in the code folder
#
# If there is no such file, then it writes a message to this effect to stdout.
# It then drops any firewall rules on the master vagrant box (this is
# typically handled by the seteam demo code).
#
# (This results in a stock PE environment with no demo code or modules.)

PATH="/opt/puppetlabs/bin:/opt/puppetlabs/puppet/bin:/opt/puppet/bin:$PATH"
g_puppet_environmentpath=$(puppet config print environmentpath)

##############################################################################
# Main execution
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
##############################################################################
main()
{
	repos_tarball=$(find /vagrant/code -name *.tar.gz)
	if [ ! -z "$repos_tarball" ]; then
		install_with_environment "$repos_tarball"
	else
		install_without_environment
	fi
}

##############################################################################
# Install the repos tarball and use r10k to extract the environment
# Globals:
#   g_puppet_environmentpath
# Arguments:
#   path_to_repos_tarball
# Returns:
#   None
##############################################################################
install_with_environment()
{
	mkdir -p /opt/puppetlabs/repos
	tar xzf "$1" -C /opt/puppetlabs/repos --strip 1
	cat > /etc/puppetlabs/r10k/r10k.yaml <<-EOF
		:cachedir: /var/cache/r10k
		:sources:
		  puppet:
		    basedir: $g_puppet_environmentpath
		    remote: /opt/puppetlabs/repos/control-repo.git
	EOF
	r10k deploy environment -p -v

	/bin/bash "${g_puppet_environmentpath}/production/scripts/deploy.sh"
}


##############################################################################
# Set up some basics on the Puppet master that do not require the environment
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
##############################################################################
install_without_environment()
{
	# No SETeam demo tarball. Initialize a vanilla PE Master
	echo "The seteam demo tarball was not found."
	echo "Removing firewall rules to allow agents to communicate with the master."

	# Include some helper functions that we need for initialization
	#
	# $BASH_SOURCE[0] and $0 will always be `/tmp/vagrant-shell` when running
	# under vagrant.  Hardcode correct directory as /vagrant/scripts if we see a
	# directory at `/vagrant`, otherwise derive from above variables.
	if [ -d "/vagrant" ] ; then
		script_dir="/vagrant/scripts"
	else
		script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
	fi
	source ${script_dir}/lib/no_tarball_support_functions.sh

	# Run all possible commands to ensure that the firewall is down on EL 6 or 7.
	# At least one of these is going to fail. That's why they're all silenced.
	iptables -F 2>/dev/null || true
	chkconfig iptables off 2>/dev/null || true
	systemctl disable firewalld 2>/dev/null || true

	# Use the puppet-classify gem to classify the master with the necessary pe_repo::platform classes
	#gem install puppetclassify
	#ruby "${script_dir}/classify_pe_master_group.rb"

	# Wait for the initial puppet run to complete on the master before proceeding.
	# This will ensure that the support classes are evaluated before we try
	# to create any agent VMs.
	wait_for_initial_puppet_run
}

# In order to allow individuals to easily customize their bootstrap, -pre and
# -post scripts will be run, if they exist.
[ -e '/vagrant/scripts/bootstrap-pre.sh' ] && source '/vagrant/scripts/bootstrap-pre.sh' || true
main "$@"
[ -e '/vagrant/scripts/bootstrap-post.sh' ] && source '/vagrant/scripts/bootstrap-post.sh' || true
