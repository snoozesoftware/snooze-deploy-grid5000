configure_storage_for_service_node () {
    # from the service node
    echo "$log_tag Starting $storage_type storage configuration procedure"

    run_taktuk "$tmp_directory/hosts_list.txt" exec "[ mkdir -p $remote_tmp_directory ]"
    put_taktuk "$tmp_directory/hosts_list.txt" "$local_scripts_directory/environment.sh" "$remote_tmp_directory/environment.sh"
    put_taktuk "$tmp_directory/hosts_list.txt" "$local_scripts_directory/prepare_environment_service_node.sh" "$remote_tmp_directory/prepare_environment_service_node.sh"
    # create the directory to mount on the nodes
    run_taktuk "$tmp_directory/hosts_list.txt" exec "[ $remote_tmp_directory/prepare_environment_service_node.sh ]"

    # Starts NFS server configuration
    configure_nfs_server_on_service_node

    # Configure and mount the NFS directory on all nodes
    configure_and_mount_nfs_service_node_directory
}

configure_nfs_server_on_service_node () {
    local service_node=`cat $tmp_directory/service_node.txt`
    echo "$log_tag Configuring NFS server on the service node: $service_node"
    $remote_scripts_directory/configure_nfs_server_service_node.sh
}

# Configures NFS and mounts the directory
configure_and_mount_nfs_service_node_directory () {
    echo "$log_tag Mounting NFS storage on all other nodes"

    # make the service node address available for gm and lc
    run_taktuk "$tmp_directory/hosts_list.txt" exec "[ mkdir -p $remote_tmp_directory ]"
    put_taktuk "$tmp_directory/hosts_list.txt" "$tmp_directory/service_node.txt" "$remote_tmp_directory/service_node.txt"

    put_taktuk "$tmp_directory/hosts_list.txt" "$local_scripts_directory/configure_fstab_and_mount_nfs_directory_service_node.sh" "$remote_tmp_directory/configure_fstab_and_mount_nfs_directory_service_node.sh"
    run_taktuk "$tmp_directory/hosts_list.txt" exec "[ $remote_tmp_directory/configure_fstab_and_mount_nfs_directory_service_node.sh ]"
}
