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

## CUSTOM TOPOLOGY

sleep_time=0

custom_topology () {
 echo "$log_tag  Entering custom topology mode" 
 case "$1" in
 'init')
   echo "$log_tag Dispatching the local scripts and configure it"
   configure_packages
   init_custom_topology
   echo "-----------------"
   echo "A default topology is set see $tmp_directory/custom_topology[group_managers.txt|local_controllers.txt]"
   ;;
 'dispatch')
   echo "$log_tag Dispatching the local scripts and configure it"
   copy_localcluster_script
   configure_localcluster_script
   ;;    
 'start')
   echo "Start the cluster with the custom topology"
   start_custom_topology
   ;;
 'stop')
   echo "Stopping the cluster"
   stop_custom_topology
   ;;
 *)echo "$log_tag Unknow command received!"
   ;;
 esac
}

init_custom_topology (){
  echo "$log_tag  Initialise custom topology mode"
  cat /dev/null > $tmp_directory/custom_topology_group_managers.txt
  for i in $(cat $tmp_directory/group_managers.txt)
  do
    echo "$i,1" >> $tmp_directory/custom_topology_group_managers.txt
  done

  cat /dev/null > $tmp_directory/custom_topology_local_controllers.txt
  for i in $(cat $tmp_directory/local_controllers.txt)
  do
    echo "$i,1" >> $tmp_directory/custom_topology_local_controllers.txt
  done
  
  gms=`cat $tmp_directory/group_managers.txt | wc -l`
  start=2
  end=$gms
  cat $tmp_directory/group_managers.txt | sed -n $start,"$end"p > $tmp_directory/group_managers_left.txt
  cat $tmp_directory/group_managers.txt | head -n 1 > $tmp_directory/group_managers_first.txt
}

copy_localcluster_script (){
   echo "$log_tag Copying the localcluster file"  
   run_taktuk "$tmp_directory/hosts_list.txt" put "[ $base_directory/$root_script_directory/localcluster ] [ /tmp/ ]"
}

configure_localcluster_script(){
   echo "$log_tag  Configuring custom topology"
   settings_path="$base_directory/$root_script_directory/localcluster/scripts/settings.sh"
   mcast_port=10000
   for i in $(cat $tmp_directory/custom_topology_group_managers.txt) 
   do
      node=`echo $i | cut -f1 -d","`
      gms=`echo $i | cut -f2 -d","`
      perl -p -e "s/^number_of_group_managers.*/number_of_group_managers=$gms/" "$settings_path" > $tmp_directory/$node.settings.sh
      perl -pi -e "s/^number_of_bootstrap_nodes.*/number_of_bootstrap_nodes=0 /" "$tmp_directory/$node.settings.sh"
      perl -pi -e "s/^number_of_local_controllers.*/number_of_local_controllers=0/" "$tmp_directory/$node.settings.sh"
      perl -pi -e "s/^sleep_time.*/sleep_time=$sleep_time/" "$tmp_directory/$node.settings.sh"
      perl -pi -e "s/^start_group_manager_heartbeat_mcast_port.*/start_group_manager_heartbeat_mcast_port=$mcast_port/" "$tmp_directory/$node.settings.sh" 
      run_taktuk_single_machine "$node" put "[ $tmp_directory/$node.settings.sh ] [ /tmp/localcluster/scripts/settings.sh ]"
      mcast_port=$(($mcast_port+$gms))
  done

  for i in $(cat $tmp_directory/custom_topology_local_controllers.txt) 
  do
     node=`echo $i | cut -f1 -d","`
     lcs=`echo $i | cut -f2 -d","`
     perl -p -e "s/^number_of_local_controllers.*/number_of_local_controllers=$lcs/" "$base_directory/$root_script_directory/localcluster/scripts/settings.sh" > $tmp_directory/$node.settings.sh
      perl -pi -e "s/^number_of_bootstrap_nodes.*/number_of_bootstrap_nodes=0/" "$tmp_directory/$node.settings.sh"
      perl -pi -e "s/^number_of_group_managers.*/number_of_group_managers=0/" "$tmp_directory/$node.settings.sh"
      perl -pi -e "s/^sleep_time.*/sleep_time=$sleep_time/" "$tmp_directory/$node.settings.sh"
      run_taktuk_single_machine "$node" put "[ $tmp_directory/$node.settings.sh ] [ /tmp/localcluster/scripts/settings.sh ]"
  done
}

start_custom_topology () {
   echo "$log_tag Starting the custom topology cluster"
   echo "$log_tag Starting the bootstrap"
   run_taktuk "$tmp_directory/bootstrap_nodes.txt" exec "[ $remote_scripts_directory/start_bootstrap.sh ]"   
   echo "$log_tag Starting the first manager"
run_taktuk_single_machine "`cat $tmp_directory/group_managers_first.txt`" exec "[ cd /tmp/localcluster ; ./start_local_cluster.sh -s 1> log 2>&1 ]" 
   sleep 1
   if [ "$sleep_time" -gt "0" ];
   then   
     echo "$log_tag Starting the other group managers incrementaly"
     for i in $(cat $tmp_directory/group_managers_left.txt)
     do
       run_taktuk_single_machine "$i"  exec "[ cd /tmp/localcluster ; ./start_local_cluster.sh -s 1> log 2>&1 ]"
       sleep $sleep_time
     done
   else 
     echo "$log_tag Starting the other group managers burst"
     run_taktuk "$tmp_directory/group_managers_left.txt"  exec "[ cd /tmp/localcluster ; ./start_local_cluster.sh -s 1> log 2>&1 ]"
   fi
   if [ "$sleep_time" -gt "0" ];
   then   
     echo "$log_tag Starting the local controllers incrementaly"
     for i in $(cat $tmp_directory/local_controllers.txt)
     do
       run_taktuk_single_machine "$i"  exec "[ cd /tmp/localcluster ; ./start_local_cluster.sh -l 1> log 2>&1  ; ./start_local_cluster.sh -s  1> log 2>&1 ]"
       sleep $sleep_time
     done
   else 
     echo "$log_tag Starting the localcontroller burst"
     run_taktuk "$tmp_directory/local_controllers.txt"  exec "[ cd /tmp/localcluster ; ./start_local_cluster.sh -l 1> log 2>&1  ; ./start_local_cluster.sh -s  1> log 2>&1 ]"
   fi
}

stop_custom_topology () {
   echo "$log_tag Stoping the custom topology cluster"
   run_taktuk "$tmp_directory/bootstrap_nodes.txt" exec "[ $remote_scripts_directory/stop_bootstrap.sh ]"
   run_taktuk "$tmp_directory/group_managers.txt"  exec "[ cd /tmp/localcluster ; ./start_local_cluster.sh -k ; rm -rf /tmp/snooze_node* ]"
   run_taktuk "$tmp_directory/local_controllers.txt"  exec "[ cd /tmp/localcluster ; ./start_local_cluster.sh -k ;./start_local_cluster.sh -d ; rm -rf /tmp/snooze_node* ]"
}
