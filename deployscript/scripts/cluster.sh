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

# Lists the cluster configuration
list_cluster_addresses() 
{
    echo "$log_tag Listing assigned cluster addresses"
    local total_hosts=$(get_total_number_of_nodes)
    echo "$log_tag Total number of hosts: $total_hosts"
    echo "$log_tag Bootstrap node addresses:" $(get_hosts_from_file "bootstrap_nodes.txt")
    echo "$log_tag Group leader/manager addresses:" $(get_hosts_from_file "group_managers.txt")
    echo "$log_tag Local controller addresses:" $(get_hosts_from_file "local_controllers.txt")  
}

# Starts the cluster
start_cluster () {
     echo "$log_tag Starting cluster"
     list_cluster_addresses
     run_taktuk "$tmp_directory/bootstrap_nodes.txt" exec "[ $remote_scripts_directory/start_bootstrap.sh ]"
     run_taktuk "$tmp_directory/group_managers.txt" exec "[ $remote_scripts_directory/start_groupmanager.sh ]"
     run_taktuk "$tmp_directory/local_controllers.txt" exec "[ $remote_scripts_directory/start_localcontroller.sh ]"
}

# Stop the cluster
stop_cluster () {
     echo "$log_tag Stoping cluster"     
     run_taktuk "$tmp_directory/bootstrap_nodes.txt" exec "[ $remote_scripts_directory/stop_bootstrap.sh ]"
     run_taktuk "$tmp_directory/group_managers.txt" exec "[ $remote_scripts_directory/stop_groupmanager.sh ]"
     run_taktuk "$tmp_directory/local_controllers.txt" exec "[ $remote_scripts_directory/stop_localcontroller.sh ]"
}
