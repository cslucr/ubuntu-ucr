# @file parameters
# @brief Handle scripts parameters.

source ./includes/messages.inc
source ./includes/vars.inc

#############################################################################
# @description Capture user input.
#
# The captured input is stored on the variables:
# - APT_CACHE
# - WGET_CACHE_PATH
# - NO_FORCE
#
# If the parameter **-h** or **--help** is found on the arguments string,
# this functions shows the help message and exits.
#
# @example
#
#  `# Get parameter from arguments string.`
#   get_parameters "$@"
#
# @arg $@ *string* arguments string.
#
# @exitcode 0 on sucess.
# @exitcode 1 on failure.
#############################################################################
function get_parameters() {

#  -y doesn't ask anything, force configuration overwriting.
#  -c prevents APT cache clean. Use this if you want cache reuse.
#  -w path absolute path to wget cache directory.
#  -h shows this help.

    while getopts c,h,w:y, option; do
        case "${option}" in
            c) APT_CACHE=true;;
            h) help; exit 0;;
            w) WGET_CACHE_PATH=$(readlink -f ${OPTARG});;
            y) NO_FORCE=false;;
        esac
    done

    # Warning Message.
    # Ask only if the user did not specify the -y parameter.
    if $NO_FORCE == true; then
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
