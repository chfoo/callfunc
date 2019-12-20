#!/bin/bash

set -e -x
SCRIPT_DIR="$PWD"/$(dirname "$BASH_SOURCE")

function download {
    local PLATFORM=$1
    mkdir -p "$SCRIPT_DIR/../out"
    cd "$SCRIPT_DIR/../out"
    source "$SCRIPT_DIR/curl_opts.sh"

    case $PLATFORM in
        windows-x86)
            FILE="hl-1.10.0-win.zip"
            ARCHIVE_DIR="hl-1.10.0-win"
            ;;
        *)
            echo "Unknown platform $PLATFORM"
            exit 2
            ;;
    esac

    curl $CURL_OPTS -O "https://github.com/HaxeFoundation/hashlink/releases/download/1.10/$FILE"

    case $FILE in
        *.tar.gz) tar -xf "$FILE" ;;
        *.zip) unzip "$FILE" ;;
    esac

    mv "$ARCHIVE_DIR" hashlink
}

function install {
    local PLATFORM=$1
    cd "$SCRIPT_DIR/../out/hashlink"

    case $PLATFORM in
        linux-x86-64|macos) install_unix ;;
        windows-x86|windows-x86-64) install_windows ;;
    esac
}

function install_unix {
    for name in hl; do
        sudo cp -p -P $name /usr/local/bin/
    done

    for name in libhl.*; do
        sudo cp -p -P $name /usr/local/lib/
    done

    for name in *.hdll; do
        sudo cp -p -P $name /usr/local/lib/
    done

    for name in include/*; do
        sudo cp -p -P $name /usr/local/include/
    done

}

function install_windows {
    mkdir -p /c/hl
    cp -R -p -P -v * /c/hl/

    echo "##vso[task.prependpath]c:/hl/"
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
