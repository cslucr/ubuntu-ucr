#!/bin/bash
#
# Handle scripts parameters.

source ./includes/messages.sh
source ./includes/vars.sh

# Capture parameters.
function get_parameters() {

    while getopts c,h,w:y, option; do
        case "${option}" in
            c) APT_CACHED=true;;
            h) help; exit 0;;
            w) WGET_CACHED=true; WGET_CACHE=$(readlink -f ${OPTARG});;
            y) NOFORCE=false;
        esac
    done

    # Warning Message.
    # Ask only if the user did not specify the -y parameter.
    if $NOFORCE == true; then
        echo ""
        echo "this script could overwrite the actual configuration, it is recommended to execute it on a fresh installation. If this is not a freshly installed system or a backup has not been made, you better cancel the process."
        echo ""
        read -p "Do you want to continue? [y/n] " -r REPLY
        if [[ ! $REPLY =~ ^[SsYy]$ ]]; then
            exit 1
        fi
    fi

    return 0
}

