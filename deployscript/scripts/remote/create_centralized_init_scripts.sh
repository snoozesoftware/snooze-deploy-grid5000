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

# Init related

if [ -f $main_init_script ]
then
    mv $main_init_script $main_init_script_backup
    sed 's/snooze_node.cfg/snooze_node_bs.cfg/g' "$main_init_script_backup" > "$bootstrap_init_script"
    perl -pi -e "s/log4j.xml/log4j_bs.xml/" "$bootstrap_init_script"
    perl -pi -e "s/snoozenode.pid/snoozenode_bs.pid/" "$bootstrap_init_script"

    sed 's/snooze_node.cfg/snooze_node_gm1.cfg/g' "$main_init_script_backup" > "$group_manager1_init_script"
    perl -pi -e "s/log4j.xml/log4j_gm1.xml/" "$group_manager1_init_script"
    perl -pi -e "s/snoozenode.pid/snoozenode_gm1.pid/" "$group_manager1_init_script"

    sed 's/snooze_node.cfg/snooze_node_gm2.cfg/g' "$main_init_script_backup" > "$group_manager2_init_script"
    perl -pi -e "s/log4j.xml/log4j_gm2.xml/" "$group_manager2_init_script"
    perl -pi -e "s/snoozenode.pid/snoozenode_gm2.pid/" "$group_manager2_init_script"

    # Log4j related
    cp $main_log4j_config $configs_directory/log4j_bs.xml
    perl -pi -e "s/snooze_node.log/snooze_node_bs.log/" "$configs_directory/log4j_bs.xml"
    cp $main_log4j_config $configs_directory/log4j_gm1.xml 
    perl -pi -e "s/snooze_node.log/snooze_node_gm1.log/" "$configs_directory/log4j_gm1.xml"
    cp $main_log4j_config $configs_directory/log4j_gm2.xml 
    perl -pi -e "s/snooze_node.log/snooze_node_gm2.log/" "$configs_directory/log4j_gm2.xml"

    # Permissions and cleanup
    chmod 755 $bootstrap_init_script $group_manager1_init_script $group_manager2_init_script $main_init_script_backup
fi

exit 0
