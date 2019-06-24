#!/bin/bash

set -e
SCRIPT_DIR="$PWD"/$(dirname "$BASH_SOURCE")

cd $SCRIPT_DIR/../test/c/examplelib

emcc -Wall -Werror -O3 examplelib.c -o $SCRIPT_DIR/../out/js/em.js \
    -s EXPORTED_FUNCTIONS='["_malloc", "_calloc", "_free", "_examplelib_f1", "_examplelib_vf1", "_examplelib_callback"]' \
    -s EXTRA_EXPORTED_RUNTIME_METHODS='["ccall", "cwrap", "addFunction", "getValue", "setValue"]' \
    -s RESERVED_FUNCTION_POINTERS=10 \
    -s ASSERTIONS=2
