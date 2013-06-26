#!/bin/bash
#
# Copyright (C) 2010-2012 Eugen Feller, INRIA <eugen.feller@inria.fr>
#
# This file is part of Snooze, a scalable, autonomic, and
# energy-aware virtual machine (VM) management framework.
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, see <http://www.gnu.org/licenses>.
#

# SSH private key
ssh_private_key="id_rsa.sid"

# SSH command
ssh_commad="ssh -i $HOME/.ssh/$ssh_private_key"

# SSH settings
user_name="root"
host_name=$1

# Image settings
name="sid-x64-mpi-snooze"
version=$2
location="$HOME/snoozeimages"
full_image_name="$name-$version.tgz"

if [ -n "$host_name" ] && [ -n "$version" ] ;
then
		echo "Creating image: $full_image_name from node: $host_name"
		$ssh_commad $user_name@$host_name tgz-g5k > "$location/$full_image_name"
        exit 0
fi

script_name=$(basename $0 .sh)
echo "Usage: $script_name host_name version"
exit 1

