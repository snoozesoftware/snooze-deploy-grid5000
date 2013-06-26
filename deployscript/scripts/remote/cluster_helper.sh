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

scriptpath=$(dirname $0)
source $scriptpath/environment.sh

# starts dstat
start_dstat () {
    $dstat -tcmn $dstat_collection_delay $dstat_collection_count > $dstat_output_file 2>&1 &
}

start_libvirt () {
    service libvirt-bin restart
}

# Starts main script
start_main () {
    if [ -f $main_init_script ]
    then
        $main_init_script start
    fi
}

# Stops main
stop_main () {
    if [ -f $main_init_script ]
    then
        $main_init_script stop
    fi
}

# Starts the bootstrap
start_bootstrap () {
    if [ -f $bootstrap_init_script ]
    then
        $bootstrap_init_script start
    fi
}

# Stops the bootstrap
stop_bootstrap () {
    if [ -f $bootstrap_init_script ]
    then
        $bootstrap_init_script stop
    fi
}

# Starts the first group manager
start_first_group_manager () {
    if [ -f $group_manager1_init_script ]
    then
        $group_manager1_init_script start
    fi
}

# Stops the first group manager
stop_first_group_manager () {
    if [ -f $group_manager1_init_script ]
    then
        $group_manager1_init_script stop
    fi
}

# Starts the second group manager
start_second_group_manager () {
    if [ -f $group_manager2_init_script ]
    then
        $group_manager2_init_script start
    fi
}

# Stops the second group manager
stop_second_group_manager () {
    if [ -f $group_manager2_init_script ]
    then
        $group_manager2_init_script stop
    fi
}

# Starts zookeeper
start_zookeeper () {
    if [ -f $zookeeper_init_script ]
    then
        $zookeeper_init_script start
    fi
}


# Stops zookeeper
stop_zookeeper () {
    if [ -f $zookeeper_init_script ]
    then
        $zookeeper_init_script stop
    fi
}

# Kills dstat
kill_dstat () {
    killall python
} 

# Kills kvm
kill_kvm () {
    killall kvm
} 
