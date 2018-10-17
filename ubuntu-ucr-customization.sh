#!/bin/bash
#
# Configures Ubuntu 18.04 LTS base system.
#
# Installed programs and configuration are tailored for the typical use for
# students, teachers and administrative personnel of University of Costa Rica.
# 
# This customization do not intents to mimick other common used systems, 
# instead it aims to provide an innovative user experience on an open source 
# desktop enviroment.
#
# This software is written by the University of Costa Rica Free Software
# Community: http://softwarelibre.ucr.ac.cr
#
# Github: https://github.com/cslucr/ubuntu-ucr

source includes/messages.inc
source includes/parameters.inc
source includes/unattended-upgrades.inc
source includes/vars.inc

# Handle parameters
get_parameters "$@"

# Handle unattended updates.
enable_unattended_upgrades

exit 0
