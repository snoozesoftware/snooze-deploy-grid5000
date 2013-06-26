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

first_bootstrap_address=`cat $tmp_directory/bootstrap_nodes.txt | head -n 1`
fstab_entry="$first_bootstrap_address:$exported_directory $exported_directory nfs $nfs_options 0 0"
#this is needed ? MATT 02/02/13 ?
mkdir $exported_directory
if grep -Fxq "$fstab_entry" /etc/fstab
then
    echo "Such fstab entry already exists!"
else
    echo -e "$fstab_entry" >> /etc/fstab 
    mount -a
fi
