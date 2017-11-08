#!/bin/bash

set -o xtrace

echo 'Starting head node'
vagrant up

./create_computes.sh 1
