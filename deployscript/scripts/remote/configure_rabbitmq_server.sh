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


rabbitmqctl add_user $rabbitmq_user $rabbitmq_password
rabbitmqctl add_vhost $rabbitmq_vhost
rabbitmqctl set_permissions -p $rabbitmq_vhost $rabbitmq_user "$rabbitmq_permissions_resource" "$rabbitmq_permissions_read" "$rabbitmq_permissions_write"
service rabbitmq-server restart
