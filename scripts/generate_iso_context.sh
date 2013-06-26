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

#save the vlan settings
save_kavlan_settings() {
  vlan_net=`route | awk 'NR>3 {print $1}' | head -n 1`
  vlan_netmask=`route | awk 'NR>3 {print $3}' | head -n 1`
   
#  vlan_netmask=`route | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n 2 | tail -n 1`
  echo "up route add -net $vlan_net  netmask $vlan_netmask dev eth0" > $tmp_directory/common_routes.txt
  echo "up route del default" >> $tmp_directory/common_routes.txt
}

generate_iso_context() {
   cp -r $deploy_script_directory/context $tmp_directory/context

#   if $multisite; then
#     save_kavlan_settings
#     cp $tmp_directory/common_routes.txt $tmp_directory/context/common/routes
#   else 
     echo "" > $tmp_directory/context/common/routes
#   fi
 
   cp $tmp_directory/common_network.txt $tmp_directory/context/common/network

   genisoimage -RJ -o $tmp_directory/context.iso $tmp_directory/context
}
