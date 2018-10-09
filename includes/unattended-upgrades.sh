#!/bin/bash
#
# Handle unattended-upgrades configuration.

source ./includes/configuration.sh

# Uncomment unattended upgrades configuration.
function enable_unattended_upgrades() {
    [[ $(enabled_unattended_upgrades) == true ]] && return 0
    replace_text /etc/apt/apt.conf.d/50unattended-upgrades '//\t"${distro_id}:${distro_codename}-updates";' '\t"${distro_id}:${distro_codename}-updates";' true
   replace_text /etc/apt/apt.conf.d/50unattended-upgrades '//Unattended-Upgrade::MinimalSteps "false";' 'Unattended-Upgrade::MinimalSteps "true";' true
    replace_text /etc/apt/apt.conf.d/50unattended-upgrade '//Unattended-Upgrade::Remove-Unused-Dependencies "false";' 'Unattended-Upgrade::Remove-Unused-Dependencies "true";' true
    return 0
}

# Comment unattended upgrades configuration.
function disable_unattended_upgrades() {
    [[ $(enabled_unattended_upgrades) == false ]] && return 0
    replace_text /etc/apt/apt.conf.d/50unattended-upgrades '\t"${distro_id}:${distro_codename}-updates";' '//\t"${distro_id}:${distro_codename}-updates";' true
    replace_text /etc/apt/apt.conf.d/50unattended-upgrades 'Unattended-Upgrade::MinimalSteps "false";' '//Unattended-Upgrade::MinimalSteps "false";' true
    replace_text /etc/apt/apt.conf.d/50unattended-upgrade 'Unattended-Upgrade::Remove-Unused-Dependencies "false";' '//Unattended-Upgrade::Remove-Unused-Dependencies "false";' true
}

# Determines if the unattended upgrades are enabled or not.
function enabled_unattended_upgrades() {
    result=$(grep '"${distro_id}:${distro_codename}-updates";' /etc/apt/apt.conf.d/50unattended-upgrades)
    ! [[ $result == *'//'* ]] && echo true && return 0
    echo false
}

