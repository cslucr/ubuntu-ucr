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
