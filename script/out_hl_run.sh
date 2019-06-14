#!/bin/bash

SCRIPT_DIR=$(dirname "$BASH_SOURCE")

LD_LIBRARY_PATH="/usr/local/lib:$SCRIPT_DIR/../out/lib/:$SCRIPT_DIR/../out/hl/:$LD_LIBRARY_PATH" hl $SCRIPT_DIR/../out/hl/test.hl $@
