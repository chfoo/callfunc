#!/bin/bash

set -e -x
SCRIPT_DIR="$PWD"/$(dirname "$BASH_SOURCE")

function download {
    mkdir -p "$SCRIPT_DIR/../out"
    cd "$SCRIPT_DIR/../out"
    source "$SCRIPT_DIR/curl_opts.sh"

    curl $CURL_OPTS -O "https://github.com/libffi/libffi/releases/download/v3.3/libffi-3.3.tar.gz"

    tar -xf libffi-3.3.tar.gz
    mv libffi-3.3 libffi
}

function install {
    cd "$SCRIPT_DIR/../out/libffi"

    ## Running autogen is only required for git sources,
    ## not needed for tarball releases
    # ./autogen.sh
    ./configure --disable-docs
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
