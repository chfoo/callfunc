#!/bin/bash

set -e
SCRIPT_DIR="$PWD"/$(dirname "$BASH_SOURCE")

function download {
    mkdir -p "$SCRIPT_DIR/../out"
    cd "$SCRIPT_DIR/../out"
    source "$SCRIPT_DIR/curl_opts.sh"

    curl $CURL_OPTS -o hashlink-1.10.tar.gz "https://github.com/HaxeFoundation/hashlink/archive/1.10.tar.gz"

    tar -xf hashlink-1.10.tar.gz
    mv hashlink-1.10 hashlink
}

function install {
    cd "$SCRIPT_DIR/../out/hashlink"

    make
    sudo make install
}

COMMAND=$1

case $COMMAND in
    download)
        download
        ;;
    install)
        install
        ;;
    *)
        echo "Unknown command $COMMAND"
        exit 2
esac
