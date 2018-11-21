#!/bin/bash
#
# Handle packages: installation and configurations.

source ./includes/vars.inc

# Given a repository index, get his data as an associative array.
function get_repository_data() {
  local digit_regex='[[:digit:]]+'
  local repository_index=$1
  result_array=$2

  # Verify repository index is a positive number.
  [[ -z "$repository_index" ]] && return 1
  ! [[ $repository_index =~ $digit_regex ]] && return 1
  
  # Verify array name was passed.
  [[ -z "$result_array" ]] && return 1

  # Test if repository index is not out of bounds.
  [[ $($YAML_PARSER r $CONFIGURATION_FILE repositories[$repository_index]) == 'null' ]] && return 1

  # Get repository data.
  result_array[repo]=$($YAML_PARSER r $CONFIGURATION_FILE repositories[$repository_index].repo)
  result_array[key]=$($YAML_PARSER r $CONFIGURATION_FILE repositories[$repository_index].key)
  result_array[unattended]=$($YAML_PARSER r $CONFIGURATION_FILE repositories[$repository_index].unattended)
  
  return 0
}

function add_repo_keyring() {
  local key=$1
  [[ -z "$key" ]] && return 1

  if [[ "$key" =~ $HTTP_REGEX ]]; then
    wget -q -O - $key | sudo apt-key add -
  else
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys $key
  fi
  return $?
}

function add_repository() {
  local repo=$1
  [[ -z "$repo" ]] && show_error "Error: No repository string" && return 1
  sudo add-apt-repository -y "$repo"
  return $?
}

function remove_repository() {
  local repo=$1
  [[ -z "$repo" ]] && show_error "Error: No repository string" && return 1
  sudo add-apt-repository -ry "$repo"
  return $?
}
