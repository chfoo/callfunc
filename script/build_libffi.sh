#!/bin/bash

set -e
SCRIPT_DIR="$PWD"/$(dirname "$BASH_SOURCE")

cd "$SCRIPT_DIR/../out/libffi"
./autogen.sh
./configure --disable-docs --prefix "$PWD/destdir"
make
make install
mkdir -p "$SCRIPT_DIR/../out/lib/libffi/"
cp "destdir/lib/libffi.so" "$SCRIPT_DIR/../out/lib/libffi/libffi.so"
