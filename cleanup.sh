#!/bin/bash

set -o xtrace

vagrant destroy -f

rm -rf opt/*
rm -rf shared/*

./remove_computes.sh
