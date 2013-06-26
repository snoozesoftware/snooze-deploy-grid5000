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

## RABBITMQ installation & configuration

install_and_configure_rabbitmq () {
   echo "$log_tag installing and configuring rabbitmq on $1"
   rabbitmq_server=`cat $tmp_directory/hosts_list.txt | head -n 1`
   echo $rabbitmq_server > $tmp_directory/rabbitmq_server.txt

   install_rabbitmq $rabbitmq_server
   
   configure_rabbitmq $1 $rabbitmq_server
     
}

install_rabbitmq () {
   echo "$log_tag installing rabbitmq on $1"
   run_taktuk_single_machine $1 exec "[ apt-get install -y --force-yes rabbitmq-server ]"
}

configure_rabbitmq () {
   echo "$log_tag installing rabbitmq on $1"
   run_taktuk_single_machine $1 exec "[ $remote_scripts_directory/configure_rabbitmq_server.sh ]"
}

