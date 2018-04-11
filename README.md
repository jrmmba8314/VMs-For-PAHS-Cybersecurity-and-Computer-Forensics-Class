# VMs-For-PAHS-Cybersecurity-and-Computer-Forensics-Class
Scripts and VMs used to create and maintain the lab environment for Port Angeles High School's Cybersecurity and Computer Forensics classes

<b>createPools.sh</b> - used to create the resource pools for the students.  Each student is manually assigned a resource pool by giving the select permissions to that student on that resource pool.

<b>addperms.sh</b> - finds next available resource pool and assigns it to the user read from the file user.txt

<b>removeperms.sh</b> - removes all the student permissions from the resource pools - this is done to start a new school year!

<b>manvms.sh</b> - the main script that creates copies of the vms; resets them to the original snapshot; and can delete, poweron, poweroff machines.

Files will be added over the next couple of weeks.  When all complete, a note will be put in the Readme file along with additional document.

NOT COMPLETED
