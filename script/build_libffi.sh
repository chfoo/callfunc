#!/bin/bash

set -e
SCRIPT_DIR="$PWD"/$(dirname "$BASH_SOURCE")

cd "$SCRIPT_DIR/../out/libffi"
./autogen.sh
./configure --disable-docs --prefix "$PWD/destdir"
make
make install
