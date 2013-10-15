#!/bin/bash
#
# Copyright (C) 2011-2012 Eugen Feller, INRIA <eugen.feller@inria.fr>
#
# This file is part of Snooze. Snooze is free software: you can
# redistribute it and/or modify it under the terms of the GNU General Public
# License as published by the Free Software Foundation, version 2.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301, USA
#

## Internal script settings
script_name=$(basename $0 .sh)
author="Eugen Feller <eugen.feller@inria.fr> Matthieu Simonin <matthieu.simonin@inria.fr>"
log_tag="[Snooze]"


multisite=true

## Exit codes
error_code=1
success_code=0

# Username and group
snooze_user="snoozeadmin"
snooze_group="snooze"

# Deploy script root directory
base_directory=$HOME
root_script_directory="snooze-deploy-grid5000"
relative_script_directory="$root_script_directory"
deploy_script_directory="$base_directory/$relative_script_directory"
# localcluster directory (for custom topology)
localcluster_script_name="snooze-deploy-localcluster"
localcluster_directory="$base_directory/$localcluster_script_name"
remote_localcluster_script_directory="/tmp/$localcluster_script_name"
# Katapult
katapult_commad="$deploy_script_directory/katapult/katapult3"

## SSH settings
ssh_private_key="$HOME/.ssh/id_rsa"
ssh_command="ssh -o PasswordAuthentication=no -o StrictHostKeyChecking=no -i $ssh_private_key"

# Script tmp directory
tmp_directory="$deploy_script_directory/tmp"

## Config names 
kapower_config_name="client_conf.yml"
ganglia_config_name="gmond.conf"
zookeeper_config_name="zoo.cfg"
zookeeper_myid="myid"
client_config_name="snooze_client.cfg"
node_config_name="snooze_node.cfg"

## Configuration templates
config_templates_directory="$deploy_script_directory/config_templates"

## Directories hosting files/scripts executed on remote hosts
remote_packages_directory="$deploy_script_directory/deb_packages"
remote_configs_directory="$deploy_script_directory/remote_configs"
remote_scripts_directory="$deploy_script_directory/scripts/remote"

#for the service node configuration
exported_directory_service_node="/tmp/service"
local_scripts_directory="$remote_scripts_directory"
#must be the same that environment.sh
remote_tmp_directory="$exported_directory_service_node/nfs"

# scp Tsunami destination
source_scpTsunami_directory="$deploy_script_directory/scpTsunami"
destination_scpTsunami_directory="/opt"
# Virtual machine image settings
destination_snooze_directory="/tmp/snooze"
source_images_directory="$base_directory/vmimages"
destination_images_directory="$destination_snooze_directory/images"

source_experiments_script_directory="$base_directory/$root_script_directory/experiments"
source_experiments_script_url="https://github.com/snoozesoftware/snooze-experiments.git"
destination_experiments_script_directory="$destination_snooze_directory/experiments"

### Cluster settings
cluster_location="rennes"
storage_type="local" # set it to local if you don't want nfs share
configure_bridge=true
bridge="virbr0"


### Deployment and installation related settings
max_deploy_runs=3
environment_location="http://public.rennes.grid5000.fr/~msimonin/envs"
environment_name="snooze-wheezy.env"
environment_url=$environment_location/$environment_name

## Cluster settings 
centralized_deployment=false
number_of_bootstrap_nodes=1
number_of_group_managers=2
number_of_local_controllers=2
number_of_subnets=1

# Deployment specific settings
multicast_address="225.4.5.6"
start_control_data_port=5000
start_monitoring_data_port=6000
start_group_manager_heartbeat_mcast_port=10000

print_settings() 
{   
    echo "<------------------------------------------->"
    echo "$log_tag Deployment user: $USER"
    echo "<------------------------------------------->"
    echo "$log_tag Centralized deployment: $centralized_deployment"
    echo "$log_tag Number of bootstrap nodes: $number_of_bootstrap_nodes"
    echo "$log_tag Number of group managers: $number_of_group_managers"
    echo "$log_tag Number of local controllers: $number_of_local_controllers"
    echo "$log_tag Number of subnets: $number_of_subnets"
    echo "<------------------------------------------->"
}
