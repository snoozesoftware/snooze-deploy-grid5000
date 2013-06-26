#!/usr/bin/ruby

# usage : ./kavlan.rb jobid file1 file2
# jobid id of the kavlan job
# file1 stores the subnets
# file2 stores the network paramters

kavlan=`kavlan -V -j #{ARGV[0]}`
b=(kavlan.to_i-10)*4+3
virtualMachineSubnets = (216..255).step(2).to_a.map{|x| "10."+b.to_s+"."+x.to_s+".1\\/23\n"}
File.open(ARGV[1], 'w') { |file| file.write(virtualMachineSubnets) }
gateway="10."+b.to_s+".255.254"
network="10."+b.to_s+".192.0"
broadcast="10."+b.to_s+".255.255"
netmask="255.255.192.0"
nameserver="131.254.203.235"
File.open(ARGV[2], 'w') { |file| file.puts("GATEWAY=#{gateway}") }
#File.open(ARGV[1], 'a') { |file| file.puts("NETWORK=#{network}") }
#File.open(ARGV[1], 'a') { |file| file.puts("BROADCAST=#{broadcast}") }
#File.open(ARGV[1], 'a') { |file| file.puts("NETMASK=#{netmask}") }
#File.open(ARGV[1], 'a') { |file| file.puts("NAMESERVER=131.254.203.235") }
File.open(ARGV[2], 'a') { |file| 
  file.puts("NETWORK=#{network}")
  file.puts("BROADCAST=#{broadcast}")
  file.puts("NETMASK=#{netmask}")
  file.puts("NAMESERVER=131.254.203.235")
}
#File.open(ARGV[1], 'a') { |file| file.puts("NETWORK=#{network}") }
#File.open(ARGV[1], 'a') { |file| file.puts("BROADCAST=#{broadcast}") }
#File.open(ARGV[1], 'a') { |file| file.puts("NETMASK=#{netmask}") }
#File.open(ARGV[1], 'a') { |file| file.puts("NAMESERVER=131.254.203.235") }
