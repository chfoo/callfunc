#!/bin/bash

SCRIPT_DIR=$(dirname "$BASH_SOURCE")

NEW_PATHS="$SCRIPT_DIR/../out/callfunc/"
NEW_PATHS+=":$SCRIPT_DIR/../out/examplelib/"
NEW_PATHS+=":/usr/local/lib/"

LD_LIBRARY_PATH="$NEW_PATHS:$LD_LIBRARY_PATH"

export LD_LIBRARY_PATH
