#!/bin/bash

# Configures Ubuntu 18.04 LTS base system.
#
# Installed programs and configuration are tailored for the typical use for
# students, teachers and administrative personal of University of Costa Rica.
# 
# This customization do not intents to mimick other common used systems, 
# instead it aims to provide an innovative user experience on a open source 
# desktop enviroment.
#
# This software is written by the University of Costa Rica Free Software
# Community: http://softwarelibre.ucr.ac.cr
#
# Github: https://github.com/cslucr/ubuntu-ucr

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

while getopts h, option
do
 case "${option}"
 in
 h) help
    exit 0 ;;
 esac
done

exit 0
