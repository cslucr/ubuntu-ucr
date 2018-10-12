#!/bin/bash
#
# Handle unattended-upgrades configuration.

source ./includes/configuration.inc

# Path to unattended updates file
UNATTENDED_UPGRADES_FILE=/etc/apt/apt.conf.d/50unattended-upgrades

# Uncomment unattended upgrades configuration.
function enable_unattended_upgrades() {
  [[ $(is_enabled_unattended_upgrades) == true ]] && return 0
  replace_text $UNATTENDED_UPGRADES_FILE '//\t"${distro_id}:${distro_codename}-updates";' '\t"${distro_id}:${distro_codename}-updates";' true
  replace_text $UNATTENDED_UPGRADES_FILE '//Unattended-Upgrade::MinimalSteps "false";' 'Unattended-Upgrade::MinimalSteps "true";' true
  replace_text $UNATTENDED_UPGRADES_FILE '//Unattended-Upgrade::Remove-Unused-Dependencies "false";' 'Unattended-Upgrade::Remove-Unused-Dependencies "true";' true
  return 0
}

# Comment unattended upgrades configuration.
function disable_unattended_upgrades() {
  [[ $(is_enabled_unattended_upgrades) == false ]] && return 0
  replace_text $UNATTENDED_UPGRADES_FILE '\t"${distro_id}:${distro_codename}-updates";' '//\t"${distro_id}:${distro_codename}-updates";' true
  replace_text $UNATTENDED_UPGRADES_FILE 'Unattended-Upgrade::MinimalSteps "false";' '//Unattended-Upgrade::MinimalSteps "false";' true
  replace_text $UNATTENDED_UPGRADES_FILE 'Unattended-Upgrade::Remove-Unused-Dependencies "false";' '//Unattended-Upgrade::Remove-Unused-Dependencies "false";' true
  return 0
}

# Determines if the unattended upgrades are enabled or not.
function is_enabled_unattended_upgrades() {
  local result=$(grep '"${distro_id}:${distro_codename}-updates";' $UNATTENDED_UPGRADES_FILE)
  ! [[ $result == *'//'* ]] && echo true && return 0
  echo false && return 0
}

# Add a new unattended upgrade if is not already added.
function add_unattended_upgrade() {
  local unattended_software=$( get_unattended_software_name "$1" "$2")
  
  # Verify software name was passed.
  [[ -z "$unattended_software" ]] && return 1

  # Verify if the upgrade is already added.
  [[ $(file_contains_string $UNATTENDED_UPGRADES_FILE $unattended_software) == true ]] && return 0

  replace_text $UNATTENDED_UPGRADES_FILE 'Unattended-Upgrade::Allowed-Origins {' 'Unattended-Upgrade::Allowed-Origins {\n\t"UNATTENDED_SOFTWARE_PLACEHOLDER";' true
  replace_text $UNATTENDED_UPGRADES_FILE 'UNATTENDED_SOFTWARE_PLACEHOLDER' "$unattended_software" true
  
  return 0
}

# Remove an unattended upgrade.
function remove_unattended_upgrade() {
  local unattended_software=$( get_unattended_software_name "$1" "$2")

  # Verify software name was passed.
  [[ -z "$unattended_software" ]] && return 1

  replace_text $UNATTENDED_UPGRADES_FILE "$unattended_software" 'UNATTENDED_SOFTWARE_PLACEHOLDER' true
  replace_text $UNATTENDED_UPGRADES_FILE '\t"LP-PPA-UNATTENDED_SOFTWARE_PLACEHOLDER:${distro_codename}";' '' true
}

# Get origin:suite format for unattended software based on repo name
function get_unattended_software_name() {
  local http_regex='https?://([-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|])'
  local repo_type=$1
  local repo_name=$2

  # Verify repository type and name.
  [[ -z "$repo_type" ]] && echo '' && return 1
  [[ -z "$repo_name" ]] && echo '' && return 1
   
  # Generates repo name for apt policy data
  case "$repo_type" in
    apt)
      repo_name=$( [[ "$repo_name" =~ $http_regex ]] && echo ${BASH_REMATCH[1]} | sed 's:/*$::' )
      ;;
    ppa)
      ;;
    *)
      echo '' && return 1
  esac
  
  #Get repo info from apt policy
  local repo_release_info=$( apt-cache policy | grep -A 2 "$repo_name" | head -n 3 )
  [[ -z "$repo_release_info" ]] && echo '' && return 1
  
  [[ "$repo_release_info" =~ o=(.*),a=(.*),n= ]] && echo ${BASH_REMATCH[1]}:${BASH_REMATCH[2]}
}

