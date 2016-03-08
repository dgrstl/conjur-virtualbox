#!/opt/puppetlabs/puppet/bin/ruby

# Use the puppetclassify gem to add the pe_repo::platform classes to the master.
# See https://github.com/puppetlabs/puppet-classify
require 'puppetclassify'

##############################################################################################
#
#  Support Function Definition
#
##############################################################################################

# Function: initialize_puppetclassify
#
# Description: Creates a PuppetClassify object that is configured to consume the PE node classifier REST API.
#              Returns the PuppetClassify object for use in all subsequent API operations
#
def initialize_puppetclassify
  # Define the url to the classifier API
  rest_api_url = 'https://master.inf.puppetlabs.demo:4433/classifier-api'

  # We need to authenticate against the REST API using a certificate
  # that is whitelisted in /etc/puppetlabs/console-services/rbac-certificate-whitelist.
  # (https://docs.puppetlabs.com/pe/latest/nc_forming_requests.html#authentication)
  #  
  # Since we're doing this on the master,
  # we can just use the internal dashboard certs for authentication
  if %x{facter -p pe_server_version} =~ /\w*/
    # PE 2015x
    ssl_dir     = '/etc/puppetlabs/puppet/ssl'
    ca_cert     = "#{ssl_dir}/ca/ca_crt.pem"
    cert_name   = 'master.inf.puppetlabs.demo'
    cert        = "#{ssl_dir}/certs/#{cert_name}.pem"
    private_key = "#{ssl_dir}/private_keys/#{cert_name}.pem"
  else
    # PE < 2015.1.0
    cert_dir    = '/opt/puppet/share/puppet-dashboard/certs'
    ca_cert     = "#{cert_dir}/ca_cert.pem"
    cert_name   = 'pe-internal-dashboard'
    cert        = "#{cert_dir}/#{cert_name}.cert.pem"
    private_key = "#{cert_dir}/#{cert_name}.private_key.pem"
  end
  auth_info = {
    'ca_certificate_path' => ca_cert,
    'certificate_path'    => cert,
    'private_key_path'    => private_key,
  }

  # Initialize and return the puppetclassify object
  puppetclassify = PuppetClassify.new(rest_api_url, auth_info)
  puppetclassify
end

# Function: define_platform_classes
#
# Description: Returns an array that defines the pe_repo::platform classes
#              that are required to support all of the agent VMs.
#
def define_platform_classes
  platform_classes = Array.new

  platform_classes.push('pe_repo::platform::el_5_x86_64')
  platform_classes.push('pe_repo::platform::el_7_x86_64')
  platform_classes.push('pe_repo::platform::ubuntu_1404_amd64')
  platform_classes.push('pe_repo::platform::debian_7_amd64')
  platform_classes.push('pe_repo::platform::sles_11_x86_64')
  platform_classes.push('pe_repo::platform::solaris_10_i386')
  platform_classes.push('pe_repo::platform::solaris_11_i386')
  platform_classes.push('pe_repo::platform::windows_x86_64')

  # Return the array of platform classes
  platform_classes
end

##############################################################################################
#
#  Script Execution
#
##############################################################################################

# Create a PuppetClassify object that is configured to consume the Node Classifier REST API.
puppetclassify = initialize_puppetclassify

# Build an array of platform support classes to add to the PE Master group
platform_classes = define_platform_classes

# Get the PE Master group from the API
#   1. Get the id of the PE Master Group
#   2. Use the id to fetch the group
pe_master_group_id = puppetclassify.groups.get_group_id('PE Master')
pe_master_group = puppetclassify.groups.get_group(pe_master_group_id)

# The Node Group API accepts a hash of classes that are assigned to the node group.
# This hash takes the following form:
#
#   { "classes" => { node_group_classes } }
#
# Each element of node_group_classes has the following form:
# 
#   { class_name => { class_parameters } }
#
# We initialize the node_grpup_classes hash here, and then add each required
# pe_repo::platform class to the hash in the loop below.
#
node_group_classes = Hash.new

# Classify the PE Master group with each platform class
platform_classes.each do |platform_class_name|
  # Get the current platform class from the production environment.
  # This ensures that the group exists before we attempt to classify the PE Master group with it.
  platform_class = puppetclassify.classes.get_environment_class('production', platform_class_name)

  # Do not set class parameters -- workaround for https://tickets.puppetlabs.com/browse/PE-12516
  # Add this class to the hash that we will add to the node group.
  # node_group_classes[platform_class['name']] = platform_class['parameters']
  node_group_classes[platform_class['name']] = {}
end

# Build a hash that defines the change we want to make to the Node Group.
# This hash takes the following form:
#
# { 
#    "id"       => node_group_id,           # pe_master_group_id, assigned above
#    "classes"  => { node_group_classes }   # this is the hash that we built in the previous loop
# }
#
# The node group API accepts a hash of values to be added, deleted or modified.
# This allows us to add all of the classes in a single operation
# by adding them to the hash and then passing the hash to the API.
#
puts "Adding required platform support classes to the #{pe_master_group['name']} Node Group"

# Build the hash to pass to the API
node_group_delta = {
  'id'      => pe_master_group_id,
  'classes' => node_group_classes
}

# Pass the hash to the API to assign the pe_repo::platform classes
puppetclassify.groups.update_group(node_group_delta)
