#!/bin/sh

########################################
#
# Creates resource pools with the name
# studentNN up to 100
# for example student01
#             student10
#             student100
#
########################################

for myCount in  $(seq 1 1 100)
do
   if [ $myCount -lt 10 ]
   then
      rpool=student0$myCount
   else
      rpool=student$myCount
   fi
   if  grep -iq "$rpool" /etc/vmware/hostd/pools.xml
   then
      echo "$rpool already exists"
   else
      echo "creating $rpool"
      vim-cmd hostsvc/rsrc/create --cpu-min-expandable=true --cpu-shares=normal --mem-min-expandable=true --mem-shares=normal ha-root-pool "$rpool" | sed -rn "s/'vim.ResourcePool:(.+)'/\1/p"
   fi
done

