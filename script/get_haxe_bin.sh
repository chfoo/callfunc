#!/bin/bash

set -e -x
SCRIPT_DIR="$PWD"/$(dirname "$BASH_SOURCE")

# install paths based on https://github.com/travis-ci/travis-build/blob/2d9a70b31e1669c4126994561a395a08b65ad737/lib/travis/build/script/haxe.rb

function download {
    local PLATFORM=$1
    mkdir -p "$SCRIPT_DIR/../out"
    cd "$SCRIPT_DIR/../out"
    source "$SCRIPT_DIR/curl_opts.sh"

    ARCHIVE_DIR="haxe_20191217082701_67feacebc"

    case $PLATFORM in
        linux-x86-64)
            FILE="haxe-4.0.5-linux64.tar.gz"
            ;;
        macos)
            FILE="haxe-4.0.5-osx.tar.gz"
            ;;
        windows-x86)
            FILE="haxe-4.0.5-win.zip"
            ;;
        windows-x86-64)
            FILE="haxe-4.0.5-win64.zip"
            ;;
        *)
            echo "Unknown platform $PLATFORM"
            exit 2
            ;;
    esac

    curl $CURL_OPTS -O "https://github.com/HaxeFoundation/haxe/releases/download/4.0.5/$FILE"

    case $FILE in
        *.tar.gz) tar -xf "$FILE" ;;
        *.zip) unzip "$FILE" ;;
    esac

    mv "$ARCHIVE_DIR" haxe
}

function install {
    local PLATFORM=$1
    cd "$SCRIPT_DIR/../out/haxe"

    case $PLATFORM in
        linux-x86-64|macos) install_unix ;;
        windows-x86|windows-x86-64) install_windows ;;
    esac
}

function install_unix {
    for name in haxe haxelib; do
        sudo cp -p -P $name /usr/local/bin/
    done

    sudo mkdir -p /usr/local/lib/haxe/
    sudo cp -R -p -P std /usr/local/lib/haxe/

    export HAXE_STD_PATH=/usr/local/lib/haxe/std

    mkdir -p ./lib
    haxelib setup ./lib
}

function install_windows {
    mkdir -p /c/haxe
    cp -R -p -P -v * /c/haxe/

    HAXE_STD_PATH="c:/haxe/std/"
    set +x
    echo "##vso[task.setvariable variable=HAXE_STD_PATH]$HAXE_STD_PATH"
    echo "##vso[task.prependpath]c:/haxe/"
    set -x

    mkdir -p /c/haxe/lib
    /c/haxe/haxelib setup c:/haxe/lib
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
