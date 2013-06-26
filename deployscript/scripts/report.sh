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

# Transfers backing virtual machine image

report() {
  service_node=`cat $tmp_directory/service_node.txt`
  rsync -avz  root@$service_node:$exported_directory_service_node/$relative_script_directory/tmp/bootstrap_nodes.txt $tmp_directory/bootstrap_nodes.txt
  rsync -avz  root@$service_node:$exported_directory_service_node/$relative_script_directory/tmp/group_managers.txt $tmp_directory/group_managers.txt
  rsync -avz  root@$service_node:$exported_directory_service_node/$relative_script_directory/tmp/local_controllers.txt $tmp_directory/local_controllers.txt
  rsync -avz  root@$service_node:$exported_directory_service_node/$relative_script_directory/tmp/rabbitmq_server.txt $tmp_directory/rabbitmq_server.txt

  bs=`cat $tmp_directory/bootstrap_nodes.txt | wc -l`
  gm=`cat $tmp_directory/group_managers.txt  | wc -l`
  lc=`cat $tmp_directory/local_controllers.txt | wc -l`
  service=`cat $tmp_directory/service_node.txt`
  rabbit=`cat $tmp_directory/rabbitmq_server.txt`
  first_bootstrap=`cat $tmp_directory/bootstrap_nodes.txt | head -n 1`

  echo "$log_tag------------ SNOOZE CLUSTER INFORMATIONS ------------"
  echo "$log_tag-- "
  echo "$log_tag-- "
  echo "$log_tag-- BOOTSTRAPS           = `echo $bs `"
  echo "$log_tag-- GROUPMANAGERS        = `echo $gm `"
  echo "$log_tag-- LOCAL CONTROLLERS    = `echo $lc `"
  echo "$log_tag------------ SPECIFIC INFORMATIONS ------------"
  echo "$log_tag-- SERVICE NODE         = `echo $service `"
  echo "$log_tag-- RABBITMQ SERVER      = `echo $rabbit `"
  echo "$log_tag-- FIRST BOOTSTRAP      = `echo $first_bootstrap `"
  echo "$log_tag-- "
  echo "$log_tag-- "
  echo "$log_tag------------ SNOOZE CLUSTER INFORMATIONS ------------"
  
}
