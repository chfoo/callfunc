#!/bin/bash

set -e
SCRIPT_DIR=$(dirname "$BASH_SOURCE")

mkdir -p "$SCRIPT_DIR/../out"
cd "$SCRIPT_DIR/../out"
if [ ! -d "libffi" ]; then
    git clone --depth 200 https://github.com/libffi/libffi.git libffi
fi
cd libffi
git checkout 80d07104c33045ea34a4d5185600495dc7461a12
