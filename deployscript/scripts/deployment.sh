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

## Deploys the image
deploy_image_vlan () {
    echo "$log_tag Starting image deployment on all hosts"

    local job_id=$(get_job_id)
    if [ -z "$job_id" ];
    then
        echo "$log_tag Did you connect to your job?!"
        return $error_code
    fi
    
    local virtual_machine_subnet=$(save_virtual_machine_subnet $job_id)
    if [ -z "$virtual_machine_subnet" ];
    then
        echo "$log_tag You must have a reservation with a subnet/kavlan reserved!"
        return $error_code
    fi

    create_hosts_list_vlan $job_id

    ## Matt : ajout du deploiement multi site
    kadeploy3 -a $environment_url -f $tmp_directory/full_hosts_list.txt  -o $tmp_directory/nodes_deployed.txt --multi-server --vlan `kavlan -V` -k 

    if [[ $? -ne $success_code ]]
    then
        echo "$log_tag Did you connect to your job?!"
        return $error_code
    fi
    get_deployed_nodes
    return $success_code
}

get_deployed_nodes(){
    cat /dev/null > $tmp_directory/deployed-kavlan.txt
     while read ligne  
    do
      echo $ligne | awk '{split($0,a,"."); print a[1]"-kavlan-"'`kavlan -V`'"."a[2]"."a[3]"."a[4]}'>>$tmp_directory/deployed-kavlan.txt
    done < $tmp_directory/nodes_deployed.txt
    cat $tmp_directory/deployed-kavlan.txt > $tmp_directory/hosts_list.txt
}



deploy_image_no_vlan () {
    echo "$log_tag Starting image deployment on all hosts"

    local job_id=$(get_job_id)
    if [ -z "$job_id" ];
    then
        echo "$log_tag Did you connect to your job?!"
        return $error_code
    fi

    local virtual_machine_subnet=$(save_virtual_machine_subnet $job_id)
    if [ -z "$virtual_machine_subnet" ];
    then
        echo "$log_tag You must have a reservation with a subnet reserved!"
        return $error_code
    fi

    create_hosts_list_no_vlan $job_id

    kadeploy3 -a  $environment_url  -f $tmp_directory/hosts_list.txt  -o $tmp_directory/nodes_deployed.txt -k 
    if [[ $? -ne $success_code ]]
    then
        echo "$log_tag Did you connect to your job?!"
        return $error_code
    fi

    return $success_code
}

