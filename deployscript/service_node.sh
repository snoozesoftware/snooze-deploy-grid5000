#!/bin/bash
#
# Copyright (C) 2010-2012 Eugen Feller, INRIA <eugen.feller@inria.fr>
#
# This file is part of Snooze, a scalable, autonomic, and
# energy-aware virtual machine (VM) management framework.
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, see <http://www.gnu.org/licenses>.
#

scriptpath=$(dirname $0)
source $scriptpath/scripts/common.sh
source $scriptpath/scripts/settings.sh
source $scriptpath/scripts/deployment.sh
source $scriptpath/scripts/package_configuration.sh
source $scriptpath/scripts/prepare_remote_environment.sh
source $scriptpath/scripts/storage.sh
source $scriptpath/scripts/transfer.sh
source $scriptpath/scripts/installation.sh
source $scriptpath/scripts/cluster.sh
source $scriptpath/scripts/networking.sh
source $scriptpath/scripts/taktuk.sh
source $scriptpath/scripts/failures.sh
source $scriptpath/scripts/dynamic_node_addition.sh
source $scriptpath/scripts/prepare_service_node.sh
source $scriptpath/scripts/storage_service_node.sh
source $scriptpath/scripts/generate_iso_context.sh
source $scriptpath/scripts/custom_topology.sh
source $scriptpath/scripts/rabbitmq.sh

# Prints the usage information
print_usage () {
    echo "Usage: $script_name [options]"
    echo "Contact: $author"
    echo "Options:"
    echo "-a                        Autoconfig"
    echo "-h                        Configure the nfs share"
    echo "-r                        Install et configure rabbitmq"
    echo "-i                        Install/Update packages"
    echo "-c                        Configure packages"
    echo "-f                        Configure storage"
    echo "-n                        Configure network (create virbr0 bridge and routes)"
    echo "-g                        Generate ISO context file"
    echo "-t                        Transfer backing virtual machine image and context file"
    echo "-e                        Transfer experiments script"
    echo "-l                        List the assigned cluster addresses"
    echo "-s                        Start cluster"
    echo "-k                        Stop cluster"
    echo "-z |init [gms] [lcs]      Init custom topology with gms GM on each GM nodes and"
    echo "   |dispatch              Dispatch the topology on node"
    echo "   |start                 Start the custom topology cluster"
    echo "   |stop                  Stop the custom topology cluster"
    echo "-o [amount] [interval]    Dynamically adds group managers"
    echo "-x [amount] [interval]    Dynamically adds local controllers"
    echo "-v [hostnames]            Simulate group manager failures"
}

# Starts autoconfiguration
autoconfig () {
    echo "$log_tag Starting in autoconfiguration mode! This can take some time, you might consider taking a coffee break :-)"

    configure_storage_for_service_node
    if [[ $? -ne $success_code ]]
    then
        return $error_code
    fi

    install_and_configure_rabbitmq
    if [[ $? -ne $success_code ]]
    then
        return $error_code
    fi
    
    # Installation and configuration
    install_packages
    if [[ $? -ne $success_code ]]
    then
        return $error_code
    fi
    
    configure_packages
    if [[ $? -ne $success_code ]]
    then
        return $error_code
    fi
    
    configure_network
    if [[ $? -ne $success_code ]]
    then
       return $error_code
    fi

    configure_storage
    if [[ $? -ne $success_code ]]
    then
        return $error_code
    fi
        
    generate_iso_context
    if [[ $? -ne $success_code ]]
    then
        return $error_code
    fi

    transfer_virtual_machine_image_and_context
    if [[ $? -ne $success_code ]]
    then
        return $error_code
    fi
    

    transfer_experiments_script
    if [[ $? -ne $success_code ]]
    then
        return $error_code
    fi
    
    start_cluster
    if [[ $? -ne $success_code ]]
    then
        return $error_code
    fi
    
    return $success_code
}

# Process the user input
option_found=0
while getopts ":rnabhicfteglsko:x:v:z:" opt; do
    option_found=1
    #print_settings

    case $opt in
        a)
            autoconfig
            return_value=$?
            ;;
        d)  
            echo "deploying image using vlan"
            deploy_image_vlan
            return_value=$?
            ;;
        h)
            configure_storage_for_service_node
            return_value=$?
            ;;
        f)
            configure_storage
            return_value=$?
            ;;
        i)
            install_packages
            return_value=$?
            ;;
        c)
            configure_packages
            return_value=$?
            ;;
        n)
            configure_network
            return_value=$?
            ;;
        g)
            generate_iso_context
            return_value=$?
            ;;
        r)
            install_and_configure_rabbitmq
            return_value=$?
            ;;
        t)
            transfer_virtual_machine_image_and_context
            return_value=$?
            ;;
        e)
            transfer_experiments_script
            return_value=$?
            ;;
        l)
            list_cluster_addresses
            return_value=$?
            ;;
        s)
            start_cluster
            return_value=$?
            ;;
        k)
            stop_cluster
            return_value=$?
            ;;
        z)
	    custom_topology $OPTARG
            return_value=$?
            ;;
             
        o)
            number_of_group_managers=$OPTARG
            eval "interval=\${$OPTIND}"
            shift 2
            add_group_managers $number_of_group_managers $interval
            ;;
        x)
            number_of_local_controllers=$OPTARG
            eval "interval=\${$OPTIND}"
            shift 2
            add_local_controllers $number_of_local_controllers $interval
            ;;
        v)
            simulate_group_manager_failures $OPTARG
            return_value=$?
            ;;
        \?)
            echo "$log_tag Invalid option: -$OPTARG" >&2
            print_usage
            exit $error_code
            ;;
        :)
            echo "$log_tag Missing argument for option: -$OPTARG" >&2
            print_usage
            exit $error_code
            ;;
    esac
done

if ((!option_found)); then
    print_usage 
    exit $error_code
fi

if [[ $return_value -ne $success_code ]]
then
    echo "$log_tag ERROR during command execution!!" >&2
    exit $error_code
fi

echo "$log_tag Command finished successfully!" >&2
exit $success_code
