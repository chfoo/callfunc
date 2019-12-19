#!/bin/bash

set -e -x
SCRIPT_DIR="$PWD"/$(dirname "$BASH_SOURCE")

mkdir -p "$SCRIPT_DIR/../out"
cd "$SCRIPT_DIR/../out"

source "$SCRIPT_DIR/curl_opts.sh"

curl $CURL_OPTS -O https://chromedriver.storage.googleapis.com/78.0.3904.105/chromedriver_linux64.zip
unzip chromedriver_linux64.zip
