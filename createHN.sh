#!/bin/bash

set -o xtrace
set -e

echo 'CREATE CLUSTER HEAD NODE'

# Get base centos image
isoName=$(curl http://mirror.atlanticmetro.net/centos/7/isos/x86_64/0_README.txt | grep -Eo 'CentOS-7-x86_64-Minimal-....\.iso')
#curl -O http://mirror.atlanticmetro.net/centos/7/isos/x86_64/${isoName}

vboxmanage createvm --name centos-HN --ostype RedHat_64  --register
vboxmanage modifyvm centos-HN --memory 3072 --acpi on \
                    --description 'HPC Cluster Head Node' \
                    --boot1 dvd --boot2 disk \
                    --nic1 bridged --bridgeadapter1 en0 --nictype1 82540EM
                    
vboxmanage createmedium disk --filename centos-HN.vdi --size 10000
vboxmanage storagectl centos-HN --name IDECtrl --add ide
VBoxManage storageattach centos-HN --storagectl IDECtrl --port 0 --device 0 \
                         --type hdd --medium centos-HN.vdi
VBoxManage storageattach centos-HN --storagectl IDECtrl --port 1 --device 0 \
                         --type dvddrive --medium ${isoName}
vboxmanage startvm centos-HN --type headless

#TODO:Figure out passing parameters for unatended OS installation
