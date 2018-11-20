# Show messages: help, errors.

# Shows help.
function help(){
  echo -e "Usage: $0 [options]

Options:

  -y \t\tdoesn't ask anything, force configuration overwriting.
  -c \t\tprevents APT cache clean. Use this if you want cache reuse.
  -w path \tabsolute path to wget cache directory.
  -h \t\tshows this help.

Customizes an Ubuntu installation.";
}

# Shows error messages and exits the script.
function error_exit(){
    show_error $1
    exit 1
}

# Shows error messages
function show_error(){
    echo "${1:-"Unknown error"}" 1>&2
}
