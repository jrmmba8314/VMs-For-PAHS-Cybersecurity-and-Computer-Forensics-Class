#!/bin/sh

########################################
#
# adds permissions from text file to 
# resource pools
#
########################################
myfile="users.txt"
if [ -f "$myfile" ] # checking if file exist
then
   myCount=1 # count through resource pools looking for ones unassigned
             # should be 1 in production.
             # don't assign pool 1
   while read line
   do
      echo "Adding $line"
      ##########
      # Look for an unassigned resource pool
      ##########
      
      foundFreePool=0
      while [ $foundFreePool == 0 ]
      do
         myCount=$((myCount+1))

         if [ $myCount -gt 100 ] # maximum number of resource pools
         then
            ##########
            # hopefully this never happens!!!!
            # so it is a BIG deal when it does!
            ##########
            echo "*******************************************"
            echo "***     We have more students than      ***"
            echo "***          Resource Pools             ***"
            echo "*******************************************"
            exit 1 # Yes, get out of script with error
         fi

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
            ###########
            # Check if resource is in use (has permissions)
            # if not add permission and stop loop
            # if does just keep looping
            ###########
 
            ##########
            # Learned that variable substitution is not liked by vim-cmd.
            # So build a string and then eval the string!
            ##########           
            execStr="vim-cmd vimsvc/auth/entity_permissions 'vim.ResourcePool:$rpoolNum' | grep -iq PAHSRM503"
            if !(eval $execStr)
            then
               echo "   added $line at ResourcePool $rpool ResourceNum $rpoolNum"
               execStr="vim-cmd vimsvc/auth/entity_permission_add 'vim.ResourcePool:$rpoolNum' \"PAHSRM503\\$line\" false Student true"
               eval $execStr
               foundFreePool=1 
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
   done < "$myfile" # double quotes important to prevent word splitting
else
  echo "*** Sorry file $myfile doesn't exist"
fi
