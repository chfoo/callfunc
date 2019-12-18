#!/bin/bash

set -e
SCRIPT_DIR="$PWD"/$(dirname "$BASH_SOURCE")

# install paths based on https://github.com/travis-ci/travis-build/blob/2d9a70b31e1669c4126994561a395a08b65ad737/lib/travis/build/script/haxe.rb

function download {
    PLATFORM=$1
    mkdir -p "$SCRIPT_DIR/../out"
    cd "$SCRIPT_DIR/../out"
    source "$SCRIPT_DIR/curl_opts.sh"

    case $PLATFORM in
        macos)
            FILE="neko-2.3.0-osx64.tar.gz"
            ARCHIVE_DIR="neko-2.3.0-osx64"
            ;;
        linux-x86-64)
            FILE="neko-2.3.0-linux64.tar.gz"
            ARCHIVE_DIR="neko-2.3.0-linux64"
            ;;
        windows-x86)
            FILE="neko-2.3.0-win.zip"
            ARCHIVE_DIR="neko-2.3.0-win"
            ;;
        windows-x86-64)
            FILE="neko-2.3.0-win64.zip"
            ARCHIVE_DIR="neko-2.3.0-win64"
            ;;
        *)
            echo "Unknown platform $PLATFORM"
            exit 2
            ;;
    esac

    curl $CURL_OPTS -O "https://github.com/HaxeFoundation/neko/releases/download/v2-3-0/$FILE"

    case $FILE in
        *.tar.gz) tar -xf "$FILE" ;;
        *.zip) unzip "$FILE" ;;
    esac

    mv "$ARCHIVE_DIR" neko
}

function install {
    PLATFORM=$1
    cd "$SCRIPT_DIR/../out/neko"

    case $PLATFORM in
        linux-x86-64|macos) install_unix ;;
        windows-x86|windows-x86-64) install_windows ;;
    esac
}

function install_unix {
    for name in neko nekoc nekom nekotools; do
        sudo cp $name /usr/local/bin/
    done

    for name in libneko.*; do
        sudo cp $name /usr/local/lib/
    done

    for name in include/*; do
        sudo cp $name /usr/local/include/
    done

    sudo mkdir -p /usr/local/lib/neko/

    for name in *.ndll; do
        sudo cp $name /usr/local/lib/neko/
    done

    sudo cp nekoml.std /usr/local/lib/neko/

    export NEKOPATH=/usr/local/lib/neko/
}

function install_windows {
    if [ -d "/mnt/c" ]; do
        C_DIR="/mnt/c"
    else
        C_DIR="/c"
    fi

    cp -r neko $C_DIR/c/

    export NEKOPATH=/c/neko/
    export PATH=$NEKOPATH:$PATH
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
