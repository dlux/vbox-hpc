#!/bin/bash

set -o xtrace

#TODO: Try it out

function _EXEC {
    echo $1
    sleep 2
    sh $2 $@
}

_EXEC 'Creating Head Node' ./createHN.sh
_EXEC 'Configure Head Node' ./configureHN.sh
_EXEC 'Create Compute Node - Setup via Head Node PXE image' ./createCN.sh 1

