# @file help
# @brief Show messages: help.

#############################################################################
# @description Shows help message.
#
# @example
#
#  `# Show help.`
#   help
#
# @noargs
#############################################################################
function help(){
  echo -e "Usage: $0 [options]

Options:

  -y \t\tdoesn't ask anything, force configuration overwriting.
  -c \t\tprevents APT cache clean. Use this if you want cache reuse.
  -w path \tabsolute path to wget cache directory.
  -h \t\tshows this help.

Customizes an Ubuntu installation.";
}

#############################################################################
# @description Shows error message and exits the script.
#
# @example
#
#  `# Show error and exit.`
#   error_exit 'An error has happened ...'
#
# @arg $1 *string* error message to show.
#############################################################################
function error_exit(){
    show_error $1
    exit 1
}

#############################################################################
# @description Shows error message.
#
# @example
#
#  `# Show error.`
#   show_error 'An error has happened ...'
#
# @arg $1 *string* error message to show.
#############################################################################
# Shows error messages
function show_error(){
    echo "${1:-"Unknown error"}" 1>&2
}
