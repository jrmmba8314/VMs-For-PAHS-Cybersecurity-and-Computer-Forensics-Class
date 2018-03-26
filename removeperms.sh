#!/bin/sh

########################################
#
# removes student permissions from all
# resources pools
#
# assumption that each resource pool
# has at the most 1 permission to remove
#
########################################
clear
echo ""

echo "*** Unrecoverable Operation  ***"
echo "*** Removing all permissions ***"
echo ""

read -p "Do you wish to continue (Y - continues)? " contchoice

if [ $contchoice == "Y" ]
then
   for myCount in $(seq 80 1 100)
   do
      if [ $myCount -lt 10 ]
      then
         rpool=student0$myCount
      else
         rpool=student$myCount
      fi
  
      ##########
      # Yes I know I am searching 
      # pools.xml twice.  Not the
      # most efficient plan but
      # works for now!
      ##########   
      if  grep -iq "$rpool" /etc/vmware/hostd/pools.xml 
      then
         rpoolNum=$(sed -rn 'N; s/\ +<name>'"$rpool"'<\/name>\n\ +<objID>(.+)<\/objID>/\1/p' /etc/vmware/hostd/pools.xml)
       
         execStr="vim-cmd vimsvc/auth/entity_permissions 'vim.ResourcePool:$rpoolNum' | grep -i PAHSRM503 | awk -F'[\\|\"]' '{print \$3}'"
         userName=$(eval $execStr)
      
         if [ ! -z "$userName"  ] 
         then
            echo "Removing person on ResourcePool $rpool ResourceNum $rpoolNum for $userName"
            execStr="vim-cmd vimsvc/auth/entity_permission_remove 'vim.ResourcePool:$rpoolNum' \"PAHSRM503\\$userName\" false "
            eval $execStr
         fi
      else
         ##########
         # this should never happen!!!!
         # so it is a BIG deal when it does!
         ##########
         echo "*******************************************"
         echo "*** Resource pool $rpool does not exits ***"
         echo "*******************************************"
         exit 1 # Yes, get out of script with error
      fi
   done
else
   echo ""
   echo "*** Exiting - No changes made ***"
fi
