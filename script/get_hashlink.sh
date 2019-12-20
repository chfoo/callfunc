#!/bin/bash

set -e -x
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

function install_msbuild {
    local PLATFORM=$1

    find_msbuild
    cd "$SCRIPT_DIR/../out/hashlink"

    case $PLATFORM in
        windows-x86)
            BUILD_PLATFORM=Win32
            ;;
        windows-x86-64)
            BUILD_PLATFORM=x64
            ;;
    esac

    "$MSBUILD" hl.sln \
        /p:Configuration=Release \
        /p:Platform=$BUILD_PLATFORM \
        /p:WindowsTargetPlatformVersion=10.0 \
        /p:PlatformToolset=v142

    mkdir -p /c/hl
    cp -R -p -P -v Release/* /c/hl/

    set +x
    echo "##vso[task.prependpath]c:/hl/"
    set -x
}

function find_msbuild {
    MSBUILD=`"c:/Program Files (x86)/Microsoft Visual Studio/Installer"/vswhere.exe -latest -requires Microsoft.Component.MSBuild -find "MSBuild/**/Bin/MSBuild.exe"`
    MSBUILD=${MSBUILD//\\/\//} # replace backslash to forward slash
}

COMMAND=$1
PLATFORM=$2

case $COMMAND in
    download)
        download $PLATFORM
        ;;
    install)
        case $PLATFORM in
            macos|linux-x86-64)
                install $PLATFORM
                ;;
            windows-x86|windows-x86-64)
                install_msbuild $PLATFORM
                ;;
            *)
                echo "Unknown platform $PLATFORM"
                ;;
        esac
        ;;
    *)
        echo "Unknown command $COMMAND"
        exit 2
esac
