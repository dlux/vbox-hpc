#!/bin/bash

set -o xtrace

n=$(( $(cat ".computesN") ))
for i in `seq 1 n`; do
    vboxmanage unregistervm "centos-CN0${i}" --delete
done
