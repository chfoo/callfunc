#!/bin/bash

set -e
SCRIPT_DIR=$(dirname "$BASH_SOURCE")

mkdir -p "$SCRIPT_DIR/../out"
cd "$SCRIPT_DIR/../out"

curl -L -s -S -f -m 60 -O "https://github.com/libffi/libffi/releases/download/v3.3/libffi-3.3.tar.gz"

tar -xf libffi-3.3.tar.gz
mv libffi-3.3 libffi
