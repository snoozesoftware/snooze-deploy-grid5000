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

## Dstat management

start_dstat(){
  run_taktuk "tmp/hosts_list.txt" exec "[ dstat -tcmnp --tcp --udp --top-mem --output /tmp/dstat.dat > dstat.log ]"
}


stop_dstat(){
  run_taktuk "tmp/hosts_list.txt" exec "[ killall python ]"
}

clean_dstat(){
  run_taktuk "tmp/hosts_list.txt" exec "[ killall python ; rm -rf /tmp/dstat* ]"
}

