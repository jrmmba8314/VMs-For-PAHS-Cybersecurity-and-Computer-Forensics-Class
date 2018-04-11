# VMs-For-PAHS-Cybersecurity-and-Computer-Forensics-Class
Scripts and VMs used to create and maintain the lab environment for Port Angeles High School's Cybersecurity and Computer Forensics classes.  Lab directions, assignments, and videos can be found at http://cybersecurity.portangelesschools.org

<b>createPools.sh</b> - used to create the resource pools for the students.  Each student is manually assigned a resource pool by giving the select permissions to that student on that resource pool.

<b>addperms.sh</b> - finds next available resource pool and assigns it to the user read from the file user.txt

<b>removeperms.sh</b> - removes all the student permissions from the resource pools - this is done to start a new school year!

<b>manvms.sh</b> - the main script that creates copies of the vms; resets them to the original snapshot; and can delete, poweron, poweroff machines.  The script is menu driven.  I do send much info the screen.  I like to see what is going on.

The actual vms used are:

<ul>
   <li><b>android6</b> - adopted from http://www.android-x86.org/releases/releasenote-6-0-r3 <br>
   Modified to work on ESXi <br>
   download from http://cybersecurity.portangelesschools.org/android6.zip</li>
   
   <li><b>ctf8</b> - adopted from https://sourceforge.net/projects/lampsecurity/files/CaptureTheFlag/CTF8/ <br>
   Modified to allow script to automatically set static ips <br>
   download from http://cybersecurity.portangelesschools.org/ctf8.zip</li>
   
   <li><b>KaliRolling</b> - main Kali install with various updates. <br>
   From https://www.kali.org/ <br>
   download from http://cybersecurity.portangelesschools.org/KaliRolling/zip</li>
   
   <li><b>ProgrammingUbuntu</b> - main Ubuntu with a variety of programming environments installed. <br>
   Originally from https://www.ubuntu.com/ <br>
   download from http://cybersecurity.portangelesschools.org/ProgrammingUbuntu.zip</li>
   
   <li><b>PureWindows10</b> - install of Microsoft Windows 10. Just a straight install with no updates nor configurations. No vm posted due to copyright issues.<br></li>
   
   <li><b>UbuntuForensics</b> - adopted from https://digital-forensics.sans.org/community/downloads<br></li>
   
   <li><b>VulnerableWebApps</b> - adopted from http://www.vulnerablewebapps.org/ Modified to allow script to automatically set static ips<br></li>
   
   <li><b>Windows2012R2</b> - install of Microsoft Windows Server 2012R2. Just a straight install with no updates nor configurations. No vm posted due to copyright issues.<br></li>
</ul>

NOT COMPLETED
