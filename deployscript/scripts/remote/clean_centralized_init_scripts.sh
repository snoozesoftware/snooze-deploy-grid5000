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

rm -Rf $bootstrap_config_file
rm -Rf $groupmanager1_config_file
rm -Rf $groupmanager2_config_file

rm -Rf $bootstrap_log4j_file
rm -Rf $groupmanager1_log4j_file
rm -Rf $groupmanager2_log4j_file

rm -Rf $bootstrap_init_script
rm -Rf $group_manager1_init_script
rm -Rf $group_manager2_init_script

# Restore config file
if [ -f $main_init_script_backup ]
then
    mv $main_init_script_backup $main_init_script
fi

exit 0
