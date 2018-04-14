#!/bin/sh
clear

########################################
#
# This is the main script used to
# manage the VMs for PAHS Cybersecurity
# class.  April 1, 2018 by John Mitchell
#
########################################
#
# If ssh command fails, try enabling
# sshClient for ESXI firewall
#
# esxcli network firewall ruleset set --enabled true --ruleset-id=sshClient
#
########################################
#
# for a good resource see
# https://github.com/cloudbase/unattended-setup-scripts/tree/master/esxi
#
########################################

########################################
# Select VM to manipulate
########################################

echo "Pick letter of vm to manipulate:"
echo ""
echo "a) android6"
echo "c) ctf8"
echo "k) KaliRolling"
echo "u) ProgrammingUbuntu"
echo "w) PureWindows10"
echo "f) UbuntuForensics"
echo "v) VulnerableWebApps"
echo "s) Windows2012R2"
echo "q) Quit"

read -p "Choice: " vmchoice 
echo ""

needsIP=0
configFile=""
case $vmchoice in
   a) workingvm="android6";;
   c) needsIP=1;
      configFile="/etc/sysconfig/network-scripts/ifcfg-eth0";
      workingvm="ctf8";;
   k) workingvm="KaliRolling";;
   u) workingvm="ProgrammingUbuntu";;
   w) workingvm="PureWindows10";;
   f) workingvm="UbuntuForensics";;
   v) needsIP=1;
      configFile="/etc/network/interfaces";
      workingvm="VulnerableWebApps";;
   s) workingvm="Windows2012R2";;
   q) echo "*** Bye";
      exit 0;;
   *) echo "*** Invalid VM choice";
      exit 1;;
esac

echo "*** Working with VM $workingvm"

########################################
# Select a manipulation to perform
########################################

echo "Pick the number of the manipulation to perform:"
echo ""
echo "1) PowerOn"
echo "2) PowerOff"
echo "3) Revert"
echo "4) Recreate"
echo "5) Delete Remove"
echo "0) Quit"

read -p "Choice: " manchoice
echo ""

case $manchoice in
   1) workingman="PowerOn";;
   2) workingman="PowerOff";;
   3) workingman="Revert";;
   4) workingman="Recreate";;
   5) workingman="Delete Remove";;
   0) echo "*** Bye";
      exit 0;;
   *) echo "*** Invalid Manipulation Choice";
      exit 1;;
esac
                              
echo "*** Working with VM $workingvm doing $workingman"

#######################################
# warn people of destructive process 
#
# Left as a series of ORs instead of -gt
# for future expansion 
# (what if option 6 is not destructive)
####################################### 
if [ $manchoice == 3 -o $manchoice == 4 -o $manchoice == 5 ]
then
   echo "*** Unrecoverable Operation ***"
   if [ $manchoice == 5 ]
   then
      echo "*** $workingman will delete ALL VM $workingvm"
   else
      echo "*** $workingman will reset ALL VM $workingvm to original settings"
   fi
   
   if [ $manchoice = 4 ]
   then
      echo "*** this procedure takes a looooonnnnnggggg time!!!"
   fi
   
   echo ""
   read -p "Do you wish to continue (Y - continues)? " contchoice
   
   if [ $contchoice != "Y" ]
   then
      echo ""
      echo "*** Exiting!!! ***"
      exit 0 # not continuing so just exit script
   fi
fi

########################################
# We have what we need, let's get to work
########################################

echo ""

if [ $manchoice != 4 ]
then
   for vmmachine in $(vim-cmd vmsvc/getallvms | grep $workingvm | vim-cmd vmsvc/getallvms | grep $workingvm | awk '{print $1}' | sort -n)
   do
      case $manchoice in
         1) ###############
            # PowerOn
            ###############
            # in version 6+ a timeout exist for asking
            # whether the vm has been copies or moved
            # Default is copied so I just let the question
            # time out.
            # This timeout default is 4 minutes.
            # I tried to changed it to 15 seconds.
            # Still working on this
            # https://kb.vmware.com/s/article/2113542
            # so I just force the question
            # 
            # Note to get the seconds use date +%s
            echo "powering on $vmmachine"
            execStr="vim-cmd vmsvc/power.on $vmmachine &"
            eval $execStr
            sleep 30

            msgId=$(vim-cmd vmsvc/message $vmmachine | grep "Virtual machine message" | sed "s/Virtual Machine message//" | sed "s/Virtual//; s/machine//; s/message//; s/://;s/ //g")
            if [ "$msgId" != "" ]
            then
               execStr="vim-cmd vmsvc/message $vmmachine $msgId 2"
               eval $execStr
            fi;;

         2) ###############
            # PowerOff
            ###############
            echo "powering off $vmmachine"
			execStr="vim-cmd vmsvc/power.off $vmmachine"
            eval $execStr;;

         3) ###############
            # Revert
            ###############
            echo "reverting $vmmachine"
            execStr="vim-cmd vmsvc/snapshot.revert $vmmachine 1 1"
            eval $execStr;;
            
         5) ###############
            # Delete Remove
            ###############
            echo "deleting removing $vmmachine"
            execStr="vim-cmd vmsvc/power.off $vmmachine"
            eval $execStr
            sleep 30 # just make sure it is off
            
            execStr="vim-cmd vmsvc/destroy $vmmachine"
            eval $execStr;;
      esac
   done
   exit 0
else
   ###############
   # Recreate
   ###############

   echo "Recreate"
   
   ###############
   # Delete current first
   ###############
   for vmmachine in $(vim-cmd vmsvc/getallvms | grep $workingvm | vim-cmd vmsvc/getallvms | grep $workingvm | awk '{print $1}'  | sort -n)
   do
	  echo "Deleting $vmmachine"
      execStr="vim-cmd vmsvc/power.off $vmmachine"
      eval $execStr
      sleep 30 # just make sure it is off

      execStr="vim-cmd vmsvc/destroy $vmmachine"
	  eval $execStr
   done
   
   for myCount in $(seq 1 1 10)  # JRMMBA - in production this is 100
   do
      if [ $myCount -lt 10 ]
      then
         rpool="student0$myCount"
         NumWorkingvm="$workingvm"0"$myCount"
      else
         rpool="student$myCount"
         NumWorkingvm="$workingvm""$myCount"
      fi
      
      ##########
      # If needed create directory
      ##########
      directory="/vmfs/volumes/StudentVMs/$workingvm/$NumWorkingvm"
	  echo "*** Working with $directory ***"
      
      if [ ! -d "$directory" ]
      then
         echo "   Create directory"
         mkdir $directory
      fi
      
      ##########
      # copy over main file
      ##########
	  echo "   Copying main file"
      execStr="vmkfstools -i \"/vmfs/volumes/SYSTEMS/$workingvm/$workingvm.vmdk\" -d thin \"$directory/$workingvm.vmdk\""
	  eval $execStr
      
      ##########
      # copy over rest of files
      ##########
	  echo "   Copying rest of files"
      execStr="find \"/vmfs/volumes/SYSTEMS/$workingvm/\" -maxdepth 1 -type f -print | grep -v \".vmdk\" | while read file; do cp \"\$file\" \"$directory\"; done;"
	  eval $execStr

      ##########
      # register the vm 
      ##########
	  echo "   Registering"
      rpoolNum=$(sed -rn 'N; s/\ +<name>'"$rpool"'<\/name>\n\ +<objID>(.+)<\/objID>/\1/p' /etc/vmware/hostd/pools.xml)
      execStr="vim-cmd solo/registervm \"$directory/$workingvm.vmx\" $NumWorkingvm $rpoolNum"
	  eval $execStr

      if [ $needsIP == 0 ]
      then
         ##########
         # create original snapshot
         ##########      
	     echo "   Create Snapshot"
         execStr="vim-cmd vmsvc/getallvms | grep $NumWorkingvm | vim-cmd vmsvc/getallvms | grep $NumWorkingvm | awk '{print \$1, \"Original\"}'  | xargs vim-cmd vmsvc/snapshot.create"
	     eval $execStr
	  else
         echo "   Wait for Snapshot.  Needs IP Address";
      fi
      
   done
   
   #########
   # If needed, update IP address
   #########
   if [ $needsIP == 1 ]
   then
      echo ""
	  echo "*** Needs Static IP - $workingvm" 
      for vmmachine in $(vim-cmd vmsvc/getallvms | grep $workingvm | vim-cmd vmsvc/getallvms | grep $workingvm | awk '{print $1}'  | sort -n)
      do
         ###############
         # PowerOn
         ###############
         # in version 6+ a timeout exist for asking
         # whether the vm has been copies or moved
         # Default is copied so I just let the question
         # time out.
         # This timeout default is 4 minutes.
         # I tried to changed it to 15 seconds.
         # Still working on this
         # https://kb.vmware.com/s/article/2113542
         # so instead of just force the question
         # 
         # Note to get the seconds use date +%s
         echo "   powering on $vmmachine"
         execStr="vim-cmd vmsvc/power.on $vmmachine &"
         eval $execStr
         sleep 30
         
         msgId=$(vim-cmd vmsvc/message $vmmachine | grep "Virtual machine message" | sed "s/Virtual Machine message//" | sed "s/Virtual//; s/machine//; s/message//; s/://;s/ //g")
         if [ "$msgId" != "" ]
         then
            execStr="vim-cmd vmsvc/message $vmmachine $msgId 2"
            eval $execStr
         fi
      done

      ##########
      # Wait 5 minutes for all machines to take the default to the moved / copied question
      # And make sure all are through booting up.  Nothing magically about the time
      # Just seemed right in my lab setting
      ##########
      maxMinutes=5  # this number is still in test mode JRMMBA should be 10
      echo "   Sleeping for $maxMinutes"
      for myMinutes in $(seq 1 1 $maxMinutes)
      do
         echo "   ---> Sleeping minute $myMinutes"
         sleep 60   # I did the loop so I could echo every minute.  The screen
                    # disappearing for that long made me nervous.
      done
      
      for vmmachine in $(vim-cmd vmsvc/getallvms | grep $workingvm | vim-cmd vmsvc/getallvms | grep $workingvm | awk '{print $1}'  | sort -n)
      do
         ###############
         # Power off.  We can only have 1 machine on at a time to do the rest of the work
         # Should all be at a terminal user signon prompt, so this should be safe to do.
         ###############
         echo "   powering off $vmmachine"
         execStr="vim-cmd vmsvc/power.off $vmmachine"
         eval $execStr
      done
      
      ##########
      # The next steps assign a static ip address to these servers.
      # The students could not do this as they are not suppose to know
      # the root passwords!  Getting root access to these servers
      # is part of the lab experience.
      # I tried using a plain text password to sign on to ssh using something like:
      #       echo "Setting up password file"
      #       echo "echo $passwd" > /tmp/1
      #       chmod 777 /tmp/1
      #       export SSH_ASKPASS="/tmp/1"
      #       export DISPLAY=MYOWNDISPLAY
      #       setsid ssh -o StrictHostKeyChecking=no root@172.17.0.50
      # this got "messy" with the environment variables and the extra processes
      # so switched to a key gen approach using
      # https://askubuntu.com/questions/115151/how-to-set-up-passwordless-ssh-access-for-root-user
      # 
      ##########
      
      for vmmachine in $(vim-cmd vmsvc/getallvms | grep $workingvm | vim-cmd vmsvc/getallvms | grep $workingvm | awk '{print $1}' | sort -n)
      do
         NumWorkingvm=$(vim-cmd vmsvc/getallvms | grep $vmmachine | awk '{print $2}')
         
         vmNum=$(echo "$NumWorkingvm" | sed "s/$workingvm//")
         
         ##########
         # Set up command file
         echo "   Setting up command file"
         echo "sed -i -e 's/172.17.0.1/172.18.0.1/g' \"$configFile\"" > /tmp/2
         echo "sed -i -e 's/172.17.0.50/172.18.0.$vmNum/g' \"$configFile\"" >> /tmp/2
         echo "poweroff" >> /tmp/2
         chmod 777 /tmp/2
         
         ##########
         # ssh over to the server and power off machine.
         # The template server as a fixed address of 172.17.0.50 
         # first wipe out known_hosts.  Old keys cause problems
         sed -i '/172.17.0.50/d' /.ssh/known_hosts
         echo "   powering on $vmmachine"
         execStr="vim-cmd vmsvc/power.on $vmmachine &"
         eval $execStr
         sleep 30
         
         msgId=$(vim-cmd vmsvc/message $vmmachine | grep "Virtual machine message" | sed "s/Virtual Machine message//" | sed "s/Virtual//; s/machine//; s/message//; s/://;s/ //g")
         if [ "$msgId" != "" ]
         then
            execStr="vim-cmd vmsvc/message $vmmachine $msgId 2"
            eval $execStr
         fi

         ##########
         # wait for machine to completely boot up
         echo "   Updating ip configure"
         ping -c1 172.17.0.50 > /dev/null

         while [ $? -ne 0 ]
         do
            sleep 5
            ping -c1 172.17.0.50 > /dev/null
         done

         ssh -o StrictHostKeyChecking=no root@172.17.0.50 < /tmp/2
         
         ##########
         # wait for machine to completely shut down
         echo "   Shutting down machine"
         ping -c1 172.17.0.50 > /dev/null

         while [ $? -eq 0 ]
         do
            sleep 5
            ping -c1 172.17.0.50 > /dev/null
         done
         
         sleep 30 # need more time for machine to fully shut down

         ##########
         # done with command file
         rm /tmp/2
      
         ##########
         # update the appropriate network configuration
         echo "   Update network configuration"
         sed -i -e "s/VM Network/LabVMs/g" "/vmfs/volumes/StudentVMs/$workingvm/$NumWorkingvm/$workingvm.vmx"
         
         ##########
         # create snapshot
	     echo "   Create Snapshot"
         execStr="vim-cmd vmsvc/getallvms | grep $NumWorkingvm | vim-cmd vmsvc/getallvms | grep $NumWorkingvm | awk '{print \$1, \" Original\"}'  | xargs vim-cmd vmsvc/snapshot.create"
	     eval $execStr
      done
   else
      echo ""
      echo ""
      echo ""
      echo "*********************************************"
      echo "***  Probably want to power on / power off"
      echo "***  machines next"
      echo "*********************************************"
   fi
   exit 0
fi
