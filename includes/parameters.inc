#!/bin/bash
#
# Handle scripts parameters.

source ./includes/messages.inc
source ./includes/vars.inc

# Capture parameters.
function get_parameters() {

#  -y doesn't ask anything, force configuration overwriting.
#  -c prevents APT cache clean. Use this if you want cache reuse.
#  -w path absolute path to wget cache directory.
#  -h shows this help.

    while getopts c,h,w:y, option; do
        case "${option}" in
            c) APT_CACHED=true;;
            h) help; exit 0;;
            w) DO_WGET_CACHE=true; WGET_CACHE=$(readlink -f ${OPTARG});;
            y) NOFORCE=false;;
        esac
    done

    # Warning Message.
    # Ask only if the user did not specify the -y parameter.
    if $NOFORCE == true; then
        #TODO: i18n
        echo ""
        echo "This script could overwrite your actual configuration, it is recommended to execute it on a fresh installation. If this is not a freshly installed system or a backup has not been made, you better cancel the process."
        echo ""
        read -p "Do you want to continue? [y/n] " -r REPLY
        if [[ ! $REPLY =~ ^[SsYy]$ ]]; then
            exit 1
        fi
    fi

    return 0
}

