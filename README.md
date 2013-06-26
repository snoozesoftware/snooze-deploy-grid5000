# snoozedeploy

The Snooze Grid`5000 multi site deployement script

## Installation and Usage

* Make a reservation : 

        (frontend)$ oargridsub -t deploy -w 1:00:00 rennes:rdef="{\\\\\\\"type='kavlan-global'\\\\\\\"}/vlan=1+/slash_22=1+/nodes=3",lyon:rdef=/nodes=3,sophia:rdef=/nodes=3 > ~/oargrid.out

NB1 : On a single site you don't need to reserve a vlan. The reservation could be : 

        (frontend)$ oarsub -I -t deploy -l slash_22=1,nodes=10,walltime=8

NB2 : With a multisite reservation, the file oargrid.out is used by the script so it must be placed in your home directory.


If everything is fine this file looks like : 

    rennes:rdef={\\\"type='kavlan-global'\\\"}/vlan=1+/slash_22=1,lyon:rdef=/nodes=3,sophia:rdef=/nodes=3
    [OAR_GRIDSUB] [rennes] Date/TZ adjustment: 0 seconds
    [OAR_GRIDSUB] [rennes] Reservation success on rennes : batchId = 471354
    [OAR_GRIDSUB] [lyon] Date/TZ adjustment: 0 seconds
    [OAR_GRIDSUB] [lyon] Reservation success on lyon : batchId = 599979
    [OAR_GRIDSUB] [sophia] Date/TZ adjustment: 0 seconds
    [OAR_GRIDSUB] [sophia] Reservation success on sophia : batchId = 530702
    [OAR_GRIDSUB] Grid reservation id = 42581
    [OAR_GRIDSUB] SSH KEY : /tmp/oargrid//oargrid_ssh_key_msimonin_42581
      You can use this key to connect directly to your OAR nodes with the oar user.
   
* Connect to your job (with the subnet reservation): 

        (frontend)$ oarsub -C 471354

* Configure the proxy : 

        (frontend)$ export https_proxy="http://proxy:3128"

* Clone the git repository :

        (frontend)$ git clone https://github.com/msimonin/snooze-grid5000-multisite.git 

* Download latest version of debian package (snoozenode is require, snoozeclient is optional) : 

        (frontend)$ cd ~/snooze-grid5000-multisite/grid5000/deployscript/deb_packages/
        (frontend)$ wget https://ci.inria.fr/snooze-software/job/master-snoozenode/ws/distributions/deb-package/snoozenode_1.1.0-0_all.deb  
        (frontend)$ wget https://ci.inria.fr/snooze-software/job/master-snoozeclient/ws/distributions/deb-package/snoozeclient_1.1.0-0_all.deb  

Other packages could be found in https://ci.inria.fr/snooze-software/.

* Configure the number of nodes in the **settings.sh** and the deployment type : 

        (frontend)$ cd ~/snooze-grid5000-multisite/grid5000/deployscript/
        (frontend)$ vi scripts/settings.sh

        multisite=true|false
        storage_type="nfs|local"
        number_of_bootstrap_nodes=1
        number_of_group_managers=2
        number_of_local_controllers=5

NB : Since we use a "service node" for the deployment you will get a Snooze cluster running with n-1 nodes.
NB2 : If you set storage type to "local", the VMs base images will be propagated by scp-tsunami, you have to install it in /opt of the first bootstrap (see settings.sh of experiments scripts).

* Retrieve VMs base images in **~/vmimages/**
You can get my debian base image in /home/msimonin/vmimages in Rennes

        (frontend)$ scp -r <yourlogin>@rennes:/home/msimonin/vmimages ~/.

* Launch the automatic script :

        (frontend)$ ./snooze_deploy.sh -a

* Connection to the service node : 

        (frontend)$ cat tmp/service_node.txt
        (frontend)$ ssh -l root <service node>

* Connection to the first bootstrap : 
 
        (service)$ cd /tmp/service/snooze-grid5000-multisite/grid5000/deployscript/
        (service)$ cat tmp/bootstrap_nodes.txt
        (service)$ ssh -l root <first bootstrap>

* Launching VMs : 

The first bootstrap node hosts some helper to launch VMs.

        (bootstrap)$ cd /tmp/snooze/experiments
        (bootstrap)$ ./experiments -c test 5
        (bootstrap)$ snoozeclient start -vcn test

These commands will create and start 10 VMs.

* Visualizing the system : 
Make a tunnel (or export your display) from your laptop to the bootstrap through the grid'5000 frontend on port 5000. If snoozeclient is installed on your PC, you can launch :

        (PC) snoozeclient visualize.

## Copyright

Snooze is copyrighted by INRIA and released under the GPL v2 license (see LICENSE.txt for details). It is registered at the APP (Agence de Protection des Programmes)
under the number IDDN.FR.001.100033.000.S.P.2012.000.10000

