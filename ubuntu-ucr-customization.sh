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

source include/messages.inc
source include/parameters.inc
source include/utils.inc
source include/vars.inc

# Handle parameters.
get_parameters "$@"

# Install ansible.
[[ $(installByApt "ansible") -eq 1 ]] && exit 1

# Run playbook.
ansible-playbook -v customization.yml --extra-vars "apt_cache=$APT_CACHE wget_cache_path=$WGET_CACHE_PATH force=$FORCE arch=$ARCH" --ask-become-pass

exit 0
