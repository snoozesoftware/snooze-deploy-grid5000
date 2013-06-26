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

start_address=$(get_total_cluster_size)
end_address=0

# Returns the list of addresses
create_addresses () {
    echo "$log_tag Creating $1 addresses"
    start_address=$(($start_address + 1))
    end_address=$(($start_address + $1 - 1))
    cat $tmp_directory/hosts_list.txt | sed -n $start_address,"$end_address"p > $tmp_directory/dynamic_addresses.txt
    start_address=$end_address
}

# Dynamically adds group managers
add_group_managers () {
    echo "$log_tag Adding $1 group managers with interval $2"
    local job_id=$(get_job_id)
    local virtual_machine_subnet=$(get_virtual_machine_subnet $job_id)   
    
    local number_of_group_managers=$2
    for (( i=1; i <= $1; i++ ))
    do 
        create_deploy_start_dynamic_group_managers $number_of_group_managers
        sleep 60
        let mult=$number_of_group_managers*$2
        number_of_group_managers=$mult
    done
}

# Creates and deploys group managers dynamically
create_deploy_start_dynamic_group_managers () {
    create_addresses $1
    local group_manager_heartbeat_mcast_port=$(($start_group_manager_heartbeat_mcast_port+$1))
    local zookeeper_addresses=$(generate_zookeeper_addresses)
    
    for group_manager_address in $(cat "$tmp_directory/dynamic_addresses.txt"); do
        echo "$log_tag Creating and deploying group manager configuration for $group_manager_address as $node_config_name"
        echo $group_manager_address >> $tmp_directory/group_managers.txt
        create_group_manager_configuration $virtual_machine_subnet $start_control_data_port $start_monitoring_data_port $group_manager_heartbeat_mcast_port $zookeeper_addresses             
        deploy_group_manager_configuration $group_manager_address $node_config_name
        group_manager_heartbeat_mcast_port=$(($group_manager_heartbeat_mcast_port + 1))
    done 
    
    run_taktuk "$tmp_directory/dynamic_addresses.txt" exec "[ $remote_scripts_directory/configure_nfs_client.sh ]"
    run_taktuk "$tmp_directory/dynamic_addresses.txt" exec "[ $remote_scripts_directory/start_groupmanager.sh ]"
}

# Creates and deploys local controllers dynamically
create_deploy_start_dynamic_local_controllers () {
    create_addresses $1    
    for local_controller_address in $(cat "$tmp_directory/dynamic_addresses.txt"); do
        echo "$log_tag Creating and deploying local controller configuration for $local_controller_address as $node_config_name"
        echo $local_controller_address >> $tmp_directory/local_controllers.txt
        create_local_controller_configuration $local_controller_address
        deploy_local_controller_configuration $local_controller_address
    done 
    
    run_taktuk "$tmp_directory/dynamic_addresses.txt" exec "[ $remote_scripts_directory/configure_nfs_client.sh ]"
    run_taktuk "$tmp_directory/dynamic_addresses.txt" exec "[ $remote_scripts_directory/start_localcontroller.sh ]"
}

# Dynamically adds group managers
add_local_controllers () {
    echo "$log_tag Adding $1 local controllers with interval $2"
        
    local number_of_local_controllers=$2
    for (( i=1; i <= $1; i++ ))
    do 
        create_deploy_start_dynamic_local_controllers $number_of_local_controllers
        sleep 60
        let mult=$number_of_local_controllers*$2
        number_of_local_controllers=$mult
    done
}
