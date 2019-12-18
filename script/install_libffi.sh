#!/bin/bash

set -e
SCRIPT_DIR=$(dirname "$BASH_SOURCE")

cd "$SCRIPT_DIR/../out/libffi"

## Running autogen is only required for git sources,
## not needed for tarball releases
# ./autogen.sh
./configure --disable-docs
make
sudo make install
