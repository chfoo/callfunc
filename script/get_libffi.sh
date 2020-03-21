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

function install_vcpkg_windows {
    local PLATFORM=$1

    pushd $VCPKG_INSTALLATION_ROOT

    if [[ ! -f "./vcpkg.exe" ]]; then
        echo "vcpkg.exe not found in this directory"
        exit 1
    fi

    case $PLATFORM in
        windows-x86)
            ./vcpkg.exe install libffi:x86-windows
            ;;
        windows-x86-64)
            ./vcpkg.exe install libffi:x64-windows
            ;;
    esac

    git checkout -
    popd
}

COMMAND=$1
PLATFORM=$2

case $COMMAND in
    download)
        case $PLATFORM in
            linux-x86-64|macos)
                download
                ;;
            *)
                echo "Uknown platform $PLATFORM"
                exit 2
                ;;
        esac
        ;;
    install)
        case $PLATFORM in
            linux-x86-64|macos)
                install
                ;;
            windows-x86|windows-x86-64)
                install_vcpkg_windows $PLATFORM
                ;;
            *)
                echo "Uknown platform $PLATFORM"
                exit 2
                ;;
        esac
        ;;
    *)
        echo "Unknown command $COMMAND"
        exit 2
esac
