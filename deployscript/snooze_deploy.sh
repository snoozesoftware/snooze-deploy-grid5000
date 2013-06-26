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
source $scriptpath/scripts/taktuk.sh
source $scriptpath/scripts/prepare_service_node.sh
source $scriptpath/scripts/storage_service_node.sh
source $scriptpath/scripts/report.sh

# Prints the usage information
print_usage () {
    echo "Usage: $script_name [options]"
    echo "Contact: $author"
    echo "Options:"
    echo "-a                        Autoconfig"
    echo "-d                        Deploy image"
    echo "-h                        Prepare the service node"
    echo "-l                        Prepare and launch snooze system"
    echo "-r                        Report"
}

# Starts autoconfiguration
autoconfig () {
    echo "$log_tag Starting in autoconfiguration mode! This can take some time, you might consider taking a coffee break :-)"
    echo "Deployment time" > $tmp_directory/deployment_time.txt
    echo "Start of autoconfig | `date`" >> $tmp_directory/deployment_time.txt
 
    # Deployment
    if $multisite 
    then
      deploy_image_vlan 
    else
      deploy_image_no_vlan
    fi
    if [[ $? -ne $success_code ]]
    then
        return $error_code
    fi
    
    prepare_service_node
    if [[ $? -ne $success_code ]]
    then
        return $error_code
    fi
    
    prepare_snooze_system_and_launch
    if [[ $? -ne $success_code ]]
    then
        return $error_code
    fi

    report
    if [[ $? -ne $success_code ]]
    then
        return $error_code
    fi
    

    echo "End of autoconfig | `date`" >> $tmp_directory/deployment_time.txt
}

# Process the user input
option_found=0
while getopts ":adhlr" opt; do
    option_found=1
    print_settings

    case $opt in
        a)
            autoconfig
            return_value=$?
            ;;
        d)  
            if $multisite 
              then
              echo "deploying image using vlan"
              deploy_image_vlan 
            else
              echo "deploying image single site"
              deploy_image_no_vlan
            fi
            return_value=$?
            ;;
        h)
            echo "Preparing the service node"
            prepare_service_node
            return_value=$?
            ;;
        l) 
           echo "Preparing and launching the snooze system"
           prepare_snooze_system_and_launch
           return_value=$?
           ;;
        r) 
           echo "End of the deployment"
           report
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
