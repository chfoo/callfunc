#!/bin/bash

set -e -x
SCRIPT_DIR="$PWD"/$(dirname "$BASH_SOURCE")

function get_vars {
    case $PLATFORM in
        windows-x86)
            URL="https://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win32/Personal%20Builds/mingw-builds/8.1.0/threads-posix/dwarf/i686-8.1.0-release-posix-dwarf-rt_v6-rev0.7z/download"
            FILE="i686-8.1.0-release-posix-dwarf-rt_v6-rev0.7z"
            ARCHIVE_DIR="mingw32"
            RELEASE_NAME="i686-8.1.0-release-posix-dwarf-rt_v6-rev0"
            ;;
        windows-x86-64)
            URL="https://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds/8.1.0/threads-posix/seh/x86_64-8.1.0-release-posix-seh-rt_v6-rev0.7z/download"
            FILE="x86_64-8.1.0-release-posix-seh-rt_v6-rev0.7z"
            ARCHIVE_DIR="mingw64"
            RELEASE_NAME="x86_64-8.1.0-release-posix-seh-rt_v6-rev0"
            ;;
        *)
            echo "Unknown platform $PLATFORM"
            exit 2
            ;;
    esac
}

function download {
    local PLATFORM=$1
    mkdir -p "$SCRIPT_DIR/../out"
    cd "$SCRIPT_DIR/../out"
    source "$SCRIPT_DIR/curl_opts.sh"

    get_vars $PLATFORM

    curl $CURL_OPTS -o $FILE "$URL"

    case $FILE in
        *.tar.gz) tar -xf "$FILE" ;;
        *.zip) unzip "$FILE" ;;
        *.7z) 7z x "$FILE" ;;
    esac

    mkdir -p "$RELEASE_NAME"
    mv "$ARCHIVE_DIR" "$RELEASE_NAME"/
}

function install {
    local PLATFORM=$1
    cd "$SCRIPT_DIR/../out/"

    case $PLATFORM in
        windows-x86|windows-x86-64)
            install_windows
            ;;
        *)
            echo "Unknown platform $PLATFORM"
            exit 2
            ;;
    esac
}


function install_windows {
    get_vars $PLATFORM

    mkdir -p /c/mingw-w64
    cp -R -p -P -v "$RELEASE_NAME" /c/mingw-w64/
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
