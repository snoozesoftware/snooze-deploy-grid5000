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

#need to pass the first bootstrap address
service_node_address=`cat $tmp_directory_service_node/service_node.txt | head -n 1`

fstab_entry="$service_node_address:$exported_directory_service_node $exported_directory_service_node nfs defaults 0 0"
mkdir -p $exported_directory_service_node

if grep -Fxq "$fstab_entry" /etc/fstab
then
    echo "Such fstab entry already exists!"
else
    echo -e "$fstab_entry" >> /etc/fstab 
fi
    mount -a
