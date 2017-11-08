#/bin/bash

yum -y update
yum -y groupinstall "Development Tools"
yum -y install kernel-devel  epel-release 
yum -y install dkms

curl -O http://download.virtualbox.org/virtualbox/5.1.10/VBoxGuestAdditions_5.1.10.iso
mkdir -p /mnt/isos/VBoxGuestAdditions
mount  -o loop VBoxGuestAdditions_5.1.10.iso /mnt/isos/VBoxGuestAdditions
sh /mnt/isos/VBoxGuestAdditions/VBoxLinuxAdditions

echo "Then run  vagrant reload"
