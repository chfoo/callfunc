#!/bin/bash

set -e
SCRIPT_DIR="$PWD"/$(dirname "$BASH_SOURCE")

# install paths based on https://github.com/travis-ci/travis-build/blob/2d9a70b31e1669c4126994561a395a08b65ad737/lib/travis/build/script/haxe.rb

function download {
    PLATFORM=$1
    mkdir -p "$SCRIPT_DIR/../out"
    cd "$SCRIPT_DIR/../out"
    source "$SCRIPT_DIR/curl_opts.sh"

    ARCHIVE_DIR="haxe_20191129081926_dcfaf4ac0"

    case $PLATFORM in
        macos)
            FILE="haxe-4.0.3-linux64.tar.gz"
            ;;
        linux-x86-64)
            FILE="haxe-4.0.3-osx.tar.gz"
            ;;
        windows-x86)
            FILE="haxe-4.0.3-win.zip"
            ;;
        windows-x86-64)
            FILE="haxe-4.0.3-win64.zip"
            ;;
        *)
            echo "Unknown platform $PLATFORM"
            exit 2
            ;;
    esac

    curl $CURL_OPTS -O "https://github.com/HaxeFoundation/haxe/releases/download/4.0.3/$FILE"

    case $FILE in
        *.tar.gz) tar -xf "$FILE" ;;
        *.zip) unzip "$FILE" ;;
    esac

    mv "$ARCHIVE_DIR" haxe
}

function install {
    PLATFORM=$1
    cd "$SCRIPT_DIR/../out/haxe"

    case $PLATFORM in
        linux-x86-64|macos) install_unix ;;
        windows-x86|windows-x86-64) install_windows ;;
    esac
}

function install_unix {
    for name in haxe haxelib; do
        sudo cp $name /usr/local/bin/
    done

    sudo mkdir -p /usr/local/lib/haxe/
    sudo cp -r std /usr/local/lib/haxe/

    export HAXE_STD_PATH=/usr/local/lib/haxe/std

    sudo mkdir -p /usr/local/lib/haxe/lib
    haxelib setup /usr/local/lib/haxe/lib
}

function install_windows {
    if [ -d "/mnt/c" ]; do
        C_DIR="/mnt/c"
    else
        C_DIR="/c"
    fi

    cp -r haxe $C_DIR/c/

    export HAXE_STD_PATH=$C_DIR/c/haxe/std
    export PATH=$C_DIR/c/haxe/:$PATH

    mkdir -p $C_DIR/c/haxe/lib
    haxelib setup $C_DIR/c/haxe/lib
}

COMMAND=$1
PLATFORM=$2

case $COMMAND in
    download)
        download $PLATFORM
        ;;
    install)
        install $PLATFORM
        ;;
    *)
        echo "Unknown command $COMMAND"
        exit 2
esac
