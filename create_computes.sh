#!/bin/bash

set -o xtrace

echo 'CREATE N NUMBER OF COMPUTE NODES'
n=$(( "${$1:-1}" ))

echo n >> .computesN
exit 1
for i in `seq 1 n`; do
    createvm --name "centos-CN0${i}" --ostype Linux --register
    vboxmanage modifyvm  "centos-CN0${i}" --memory 1024 --boot1 net --chipset piix3 --nic1 intnet --nictype1 82540EM --nicpromisc1 deny --cableconnected1 on --macaddress1 0800277CF270
