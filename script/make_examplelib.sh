#!/bin/bash

set -e

SCRIPT_DIR=$(dirname "$BASH_SOURCE")

cd $SCRIPT_DIR/../test/c/examplelib
make
