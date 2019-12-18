#!/bin/bash

set -e
SCRIPT_DIR=$(dirname "$BASH_SOURCE")

cd "$SCRIPT_DIR/../out/hashlink"

make
sudo make install
