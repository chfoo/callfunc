#!/bin/bash

set -e

SCRIPT_DIR=$(dirname "$BASH_SOURCE")

mkdir -p $SCRIPT_DIR/../out
cd $SCRIPT_DIR/../out
if [ ! -d "hashlink-1.10" ]; then
    wget https://github.com/HaxeFoundation/hashlink/archive/1.10.tar.gz -O hashlink.tar.gz
fi
tar -xvf hashlink.tar.gz
cd hashlink-1.10
make
sudo make install
