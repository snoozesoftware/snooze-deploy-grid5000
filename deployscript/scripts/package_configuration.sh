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

# Configure packages
configure_packages() {
    echo "$log_tag Starting the package configuration procedure"
    
    create_component_host_files
    if [[ $? -ne $success_code ]]
    then
        return $error_code
    fi
   
    # KaPower3
    create_and_deploy_kapower_configuration
    
    # Client
    create_and_deploy_client_configuration
    
    # ZooKeeper
    create_and_deploy_zookeeper_configuration

    # Group managers
    if $centralized_deployment ; 
    then
        perform_centralized_configuration
    else
        perform_distributed_configuration
    fi
    
    # Local controllers
    create_and_deploy_local_controller_configuration
}

# Performs a centralized configuration
perform_centralized_configuration () {
    echo "$log_tag Performing centralized system connfiguration"
    create_and_deploy_bootstrap_configuration "snooze_node_bs.cfg"
    create_and_deploy_centralized_group_manager_configurations
    create_centralized_init_scripts
}

# Performs a distributed configuration
perform_distributed_configuration () {
    echo "$log_tag Performing distributed system connfiguration"
    create_and_deploy_bootstrap_configuration "snooze_node.cfg"
    create_and_deploy_distributed_group_manager_configurations
    clean_centralized_init_scripts
}

# Cleans the centralized init scripts
clean_centralized_init_scripts () {
    echo "$log_tag Updating remote centralized configuration init scripts"
    local first_host=$(get_first_host_address)
    run_taktuk_single_machine "$first_host" exec "[ $remote_scripts_directory/clean_centralized_init_scripts.sh ]"
}

# Prepares the centralized init scripts
create_centralized_init_scripts () {
    echo "$log_tag Updating remote distributed configuration init scripts"
    local first_host=$(get_first_host_address)
    run_taktuk_single_machine "$first_host" exec "[ $remote_scripts_directory/create_centralized_init_scripts.sh ]"
}

# Create and deploy kapower configuration
create_and_deploy_kapower_configuration () {
    echo "$log_tag Creating and deploying kapower3 configuration"
    create_kapower3_configuration
    deploy_kapower3_configuration
}

# Creates and deploys client configuration
create_and_deploy_client_configuration () {
    echo "$log_tag Creating and deploying client configuration"
    create_client_configuration
    deploy_client_configuration
}

# Creates and deploys bootstrap configs
create_and_deploy_bootstrap_configuration () {
    echo "$log_tag Creating and deploying bootstrap configuration as $1"
    create_bootstrap_configuration $start_control_data_port
    deploy_bootstrap_configuration $1
}

# Generates the list of zookeeper addresses
generate_zookeeper_addresses ()  {
    local zookeeper_addresses
    for bootstap_address in $(cat "$tmp_directory/bootstrap_nodes.txt"); do
        if [ -n "$zookeeper_addresses" ]; then
            zookeeper_addresses="$zookeeper_addresses,$bootstap_address:2181"
        else
            zookeeper_addresses="$bootstap_address:2181"
        fi
    done
    
    echo $zookeeper_addresses
}

# Creates and deploys group manager configs for centralized setup
create_and_deploy_centralized_group_manager_configurations () {
    local job_id=$(get_job_id)
    local virtual_machine_subnet=$(get_virtual_machine_subnet $job_id)   
    local group_manager_address=`cat $tmp_directory/group_managers.txt`
    local zookeeper_addresses=$(generate_zookeeper_addresses)
        
    echo "$log_tag Creating and deploying configuration for the first group manager on $group_manager_address"
    create_group_manager_configuration $virtual_machine_subnet $(($start_control_data_port+1)) $start_monitoring_data_port $start_group_manager_heartbeat_mcast_port $zookeeper_addresses
    deploy_group_manager_configuration $group_manager_address "snooze_node_gm1.cfg"
    
    echo "$log_tag Creating and deploying configuration for the second group manager on $group_manager_address"
    create_group_manager_configuration $virtual_machine_subnet $(($start_control_data_port+2)) $(($start_monitoring_data_port+1)) $(($start_group_manager_heartbeat_mcast_port+1)) $zookeeper_addresses
    deploy_group_manager_configuration $group_manager_address "snooze_node_gm2.cfg"
}

# Creates and deploys group manager configs for distributed setup
create_and_deploy_distributed_group_manager_configurations () {
    local job_id=$(get_job_id)
    local virtual_machine_subnet=$(get_virtual_machine_subnet $job_id)   
    local group_manager_heartbeat_mcast_port=$start_group_manager_heartbeat_mcast_port
    local zookeeper_addresses=$(generate_zookeeper_addresses)
    local rabbitmq_server=`cat $tmp_directory/rabbitmq_server.txt`
    
    for group_manager_address in $(cat "$tmp_directory/group_managers.txt"); do
        echo "$log_tag Creating and deploying group manager configuration for $group_manager_address as $node_config_name"
        create_group_manager_configuration $virtual_machine_subnet $start_control_data_port $start_monitoring_data_port $group_manager_heartbeat_mcast_port $zookeeper_addresses             $rabbitmq_server 
        deploy_group_manager_configuration $group_manager_address $node_config_name
        group_manager_heartbeat_mcast_port=$(($group_manager_heartbeat_mcast_port+1))
    done 
}

# Creates and deploys local controller configs
create_and_deploy_local_controller_configuration () {
    local rabbitmq_server=`cat $tmp_directory/rabbitmq_server.txt`
    for local_controller_address in $(cat "$tmp_directory/local_controllers.txt"); do
        echo "$log_tag Creating and deploying local controller configuration for $local_controller_address"
        create_local_controller_configuration $local_controller_address $rabbitmq_server
        deploy_local_controller_configuration $local_controller_address
    done 
}

# Creates a zookeeper configuration file
create_and_deploy_zookeeper_configuration () {
    echo "$log_tag Creating and deploying zookeeper configuration"
    
    cp "$config_templates_directory/$zookeeper_config_name" "$tmp_directory/$zookeeper_config_name" 
    local index=1
    for bootstap_address in $(cat "$tmp_directory/bootstrap_nodes.txt"); do
        echo "server.$index=$bootstap_address:2888:3888" >> "$tmp_directory/$zookeeper_config_name"
        echo $index > "$tmp_directory/$zookeeper_myid"
        run_taktuk_single_machine $bootstap_address put "[ $tmp_directory/$zookeeper_myid ] [ /etc/zookeeper/conf/$zookeeper_myid ]"
        index=$[$index+1]
    done

    run_taktuk "$tmp_directory/bootstrap_nodes.txt" put "[ $tmp_directory/$zookeeper_config_name ] [ /etc/zookeeper/conf/$zookeeper_config_name ]"
}

# Creates a kapower configuration file
create_kapower3_configuration () {
    sed 's/^default.*/default : '$cluster_location'/g' "$config_templates_directory/$kapower_config_name" > "$tmp_directory/$kapower_config_name" 
}

# Creates a client configuration file
create_client_configuration () {
    #local bootstrap_addresses=$(get_hosts_from_file "bootstrap_nodes.txt")
    bootstrap_addresses=`cat $tmp_directory/bootstrap_nodes.txt | head -n 1`
    sed 's/^general.bootstrapNodes.*/general.bootstrapNodes = '$bootstrap_addresses:$start_control_data_port'/g' "$config_templates_directory/$client_config_name" > "$tmp_directory/$client_config_name" 
}

# Creates bootstrap config
create_bootstrap_configuration () {
    sed 's/^node.role.*/node.role = bootstrap/g' "$config_templates_directory/$node_config_name" > "$tmp_directory/snooze_node_bs.cfg" 
    perl -pi -e "s/^network.listen.controlDataPort..*/network.listen.controlDataPort = $1/" "$tmp_directory/$client_config_name" 
    perl -pi -e "s/^external.notifier.address.*/external.notifier.address = $2/" "$tmp_directory/snooze_node_bs.cfg"
}

# Creates group manager config
create_group_manager_configuration () {
    echo "$log_tag Configuring group manager with parameters $1, $2, $3, $4, $5, $6"
        
    sed 's/^node.role .*/node.role = groupmanager/g' "$config_templates_directory/$node_config_name" > "$tmp_directory/snooze_node_gm.cfg" 
    perl -pi -e "s/^faultTolerance.zookeeper.hosts.*/faultTolerance.zookeeper.hosts = $5/" "$tmp_directory/snooze_node_gm.cfg"
    perl -pi -e "s/^network.virtualMachineSubnet.*/network.virtualMachineSubnet = $1/" "$tmp_directory/snooze_node_gm.cfg"
    perl -pi -e "s/^network.listen.controlDataPort.*/network.listen.controlDataPort = $2/" "$tmp_directory/snooze_node_gm.cfg"
    perl -pi -e "s/^network.listen.monitoringDataPort.*/network.listen.monitoringDataPort = $3/" "$tmp_directory/snooze_node_gm.cfg"
    perl -pi -e "s/^network.multicast.address.*/network.multicast.address = $multicast_address/" "$tmp_directory/snooze_node_gm.cfg"
    perl -pi -e "s/^network.multicast.groupManagerHeartbeatPort.*/network.multicast.groupManagerHeartbeatPort = $4/" "$tmp_directory/snooze_node_gm.cfg"
    perl -pi -e "s/^external.notifier.address.*/external.notifier.address = $6/" "$tmp_directory/snooze_node_gm.cfg"
}

#Creates local controller config
create_local_controller_configuration () {
    sed 's/^node.role.*/node.role = localcontroller/g' "$config_templates_directory/$node_config_name" > "$tmp_directory/snooze_node_lc.cfg" 
    perl -pi -e "s/^energyManagement.drivers.wakeup.options.*/energyManagement.drivers.wakeup.options = -m $1/" "$tmp_directory/snooze_node_lc.cfg"
    perl -pi -e "s/^external.notifier.address.*/external.notifier.address = $2/" "$tmp_directory/snooze_node_lc.cfg"
}

# Deploys the kapower3 configuration files
deploy_kapower3_configuration () {
    run_taktuk "$tmp_directory/hosts_list.txt" put "[ $tmp_directory/$kapower_config_name ] [ /etc/kadeploy3/$kapower_config_name ]"
}

# Deploys the client configurations
deploy_client_configuration () {
    run_taktuk "$tmp_directory/hosts_list.txt" put "[ $tmp_directory/$client_config_name ] [ /usr/share/snoozeclient/configs/$client_config_name ]"
}

# Deploys bootstrap configurations
deploy_bootstrap_configuration () {
    run_taktuk "$tmp_directory/bootstrap_nodes.txt" put "[ $tmp_directory/snooze_node_bs.cfg ] [ /usr/share/snoozenode/configs/$1 ]"
}

# Deploy group manager configuration
deploy_group_manager_configuration () {
    run_taktuk_single_machine "$1" put "[ $tmp_directory/snooze_node_gm.cfg ] [ /usr/share/snoozenode/configs/$2 ]"
}

# Deploy local controller configuration
deploy_local_controller_configuration () {
    run_taktuk_single_machine "$1" put "[ $tmp_directory/snooze_node_lc.cfg ] [ /usr/share/snoozenode/configs/$node_config_name ]"
}
