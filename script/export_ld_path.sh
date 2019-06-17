#!/bin/bash

SCRIPT_DIR=$(dirname "$BASH_SOURCE")

NEW_PATHS="$SCRIPT_DIR/../out/lib/callfunc/"
NEW_PATHS+=":$SCRIPT_DIR/../out/lib/examplelib/"
NEW_PATHS+=":$SCRIPT_DIR/../out/libffi/destdir/lib/"

LD_LIBRARY_PATH="$NEW_PATHS:$LD_LIBRARY_PATH"

export LD_LIBRARY_PATH
