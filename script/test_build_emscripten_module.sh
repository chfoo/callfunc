#!/bin/bash

set -e -x
SCRIPT_DIR="$PWD"/$(dirname "$BASH_SOURCE")

mkdir -p $SCRIPT_DIR/../out/js/
cd $SCRIPT_DIR/../test/c/examplelib

emcc -Wall -Werror -O3 examplelib.c -o $SCRIPT_DIR/../out/js/em.js \
    -s EXPORTED_FUNCTIONS='["_malloc", "_calloc", "_free", "_examplelib_ints", "_examplelib_string", "_examplelib_variadic", "_examplelib_callback"]' \
    -s EXTRA_EXPORTED_RUNTIME_METHODS='["ccall", "cwrap", "addFunction", "getValue", "setValue"]' \
    -s RESERVED_FUNCTION_POINTERS=10 \
    -s ASSERTIONS=2
