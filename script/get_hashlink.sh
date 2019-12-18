#!/bin/bash

set -e
SCRIPT_DIR=$(dirname "$BASH_SOURCE")

mkdir -p "$SCRIPT_DIR/../out"
cd "$SCRIPT_DIR/../out"

curl -L -s -S -f -m 60 -o hashlink-1.10.tar.gz "https://github.com/HaxeFoundation/hashlink/archive/1.10.tar.gz"

tar -xf hashlink-1.10.tar.gz
mv hashlink-1.10 hashlink
