#!/bin/bash

set -e

SCRIPT_DIR=$(dirname "$BASH_SOURCE")

cd $SCRIPT_DIR/../src/c/
make
