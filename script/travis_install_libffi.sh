#!/bin/bash

set -e

SCRIPT_DIR=$(dirname "$BASH_SOURCE")

$SCRIPT_DIR/get_libffi.sh
$SCRIPT_DIR/build_libffi.sh
