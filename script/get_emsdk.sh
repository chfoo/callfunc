#!/bin/bash

set -e -x
SCRIPT_DIR="$PWD"/$(dirname "$BASH_SOURCE")

mkdir -p "$SCRIPT_DIR/../out"
cd "$SCRIPT_DIR/../out"

git clone --depth 10 https://github.com/emscripten-core/emsdk emsdk

cd emsdk

./emsdk install latest
./emsdk activate latest

