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
source includes/utils.inc
source includes/vars.inc

# Handle parameters.
get_parameters "$@"

# Verify user can sudo.
! [[ "$(groups)" = *"sudo"* ]] && ! [[ "$(groups)" == *"root"* ]] && error_exit 'To run this script administrative permissions are needed.'

# Do sudo to get password to install ansible and to use on the playbook.
sudo ls &>/dev/null

# Install ansible.
[[ $(install_by_apt "ansible") -eq 1 ]] && error_exit 'Could not install ansible.'

# Run playbook.
ansible-playbook customization.yml -i production -t "execution" -v --extra-vars "apt_cache=$APT_CACHE arch=$ARCH wget_cache_path=$WGET_CACHE_PATH" 

exit 0
