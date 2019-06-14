#!/bin/bash

SCRIPT_DIR=$(dirname "$BASH_SOURCE")

LD_LIBRARY_PATH="/usr/local/lib:$SCRIPT_DIR/../out/lib/:$LD_LIBRARY_PATH" $SCRIPT_DIR/../out/cpp/TestAll-debug $@
