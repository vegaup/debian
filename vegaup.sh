#!/bin/bash

SUPPORTED_DISTROS=("Debian" "Ubuntu" "Linux Mint" "Pop!_OS" "Fedora" "RHEL")

function main() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO_NAME=$NAME
    else
        echo "Cannot determine OS distribution"
        exit 1
    fi

    SUPPORTED=false
    for distro in "${SUPPORTED_DISTROS[@]}"; do
        if [[ "$DISTRO_NAME" == *"$distro"* ]]; then
            SUPPORTED=true
            break
        fi
    done

    if [ "$SUPPORTED" = true ]; then
        if command -v apt-get &>/dev/null; then
            sudo -E bash -c "$(curl -sS https://raw.githubusercontent.com/vegaup/vegaup/main/distros/debian.sh)"
        elif command -v dnf &>/dev/null; then
            echo "RHEL-based systems are a work in progress, currently top priority is Fedora/RHEL so it shouldnt be long!"
        else
            echo "Unsupported package manager"
            exit 1
        fi
    else
        echo "Distribution $DISTRO_NAME is not supported"
        exit 1
    fi
}

main
