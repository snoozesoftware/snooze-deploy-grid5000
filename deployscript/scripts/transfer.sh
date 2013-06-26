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

transfer_virtual_machine_image_and_context () {

  transfer_backing_virtual_machine_image

  transfer_context_file

  transfer_scpTsunami

}

transfer_scpTsunami () {
    echo "$log_tag Transfering scp Tsunami"
    transfer_data "$source_scpTsunami_directory/*" "$destination_scpTsunami_directory/"
}

transfer_backing_virtual_machine_image () {
    echo "$log_tag Transfering backing virtual machine image"
    transfer_data "$source_images_directory/*" "$destination_images_directory/"
}

# Transfers the experiment script
transfer_experiments_script () {
    echo "$log_tag Transfering the experiments script"
    rm -rf $source_experiments_script_directory
    https_proxy="http://proxy:3128" git clone $source_experiments_script_url $source_experiments_script_directory
    transfer_data "$source_experiments_script_directory/*" "$destination_experiments_script_directory/"
}

transfer_context_file() {
    echo "$log_tag Transferring the context iso file"
    transfer_data "$tmp_directory/context.iso" "$destination_images_directory/."
}

# Transfers data between two hosts
transfer_data () {
    local first_bootstrap_address=$(get_first_bootstrap_address)
    echo "$log_tag Transfering the data to: $first_bootstrap_address"
    
    rsync -avz --progress --owner=$snooze_user --group=$snooze_group -e "ssh -i $ssh_private_key" $1 root@$first_bootstrap_address:$2 
    run_taktuk_single_machine "$first_bootstrap_address" exec "[ $remote_scripts_directory/fix_permissions.sh ]"
}
