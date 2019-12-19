#!/bin/bash

set -e
SCRIPT_DIR=$(dirname "$BASH_SOURCE")

mkdir -p "$SCRIPT_DIR/../out"
cd "$SCRIPT_DIR/../out"

if [ ! -d "emsdk" ]; then
    git clone --depth 10 https://github.com/emscripten-core/emsdk emsdk
fi

cd emsdk
git pull
./emsdk install latest
./emsdk activate latest

