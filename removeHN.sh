#!/bin/bash

set -o xtrace

vboxmanage controlvm centos-HN poweroff
vboxmanage storagectl centos-HN --name IDECrtl --remove
vboxmanage closemedium centos-HD.vdi --delete
vboxmanage unregistervm centos-HN --delete
